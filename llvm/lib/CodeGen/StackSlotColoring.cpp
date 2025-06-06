//===- StackSlotColoring.cpp - Stack slot coloring pass. ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the stack slot coloring pass.
//
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/StackSlotColoring.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/CodeGen/LiveDebugVariables.h"
#include "llvm/CodeGen/LiveInterval.h"
#include "llvm/CodeGen/LiveIntervalUnion.h"
#include "llvm/CodeGen/LiveIntervals.h"
#include "llvm/CodeGen/LiveStacks.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineBlockFrequencyInfo.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/PseudoSourceValue.h"
#include "llvm/CodeGen/PseudoSourceValueManager.h"
#include "llvm/CodeGen/SlotIndexes.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include <cassert>
#include <cstdint>
#include <iterator>
#include <vector>

using namespace llvm;

#define DEBUG_TYPE "stack-slot-coloring"

static cl::opt<bool>
DisableSharing("no-stack-slot-sharing",
             cl::init(false), cl::Hidden,
             cl::desc("Suppress slot sharing during stack coloring"));

static cl::opt<int> DCELimit("ssc-dce-limit", cl::init(-1), cl::Hidden);

STATISTIC(NumEliminated, "Number of stack slots eliminated due to coloring");
STATISTIC(NumDead,       "Number of trivially dead stack accesses eliminated");

namespace {

class StackSlotColoring {
  MachineFrameInfo *MFI = nullptr;
  const TargetInstrInfo *TII = nullptr;
  LiveStacks *LS = nullptr;
  const MachineBlockFrequencyInfo *MBFI = nullptr;
  SlotIndexes *Indexes = nullptr;

  // SSIntervals - Spill slot intervals.
  std::vector<LiveInterval *> SSIntervals;

  // SSRefs - Keep a list of MachineMemOperands for each spill slot.
  // MachineMemOperands can be shared between instructions, so we need
  // to be careful that renames like [FI0, FI1] -> [FI1, FI2] do not
  // become FI0 -> FI1 -> FI2.
  SmallVector<SmallVector<MachineMemOperand *, 8>, 16> SSRefs;

  // OrigAlignments - Alignments of stack objects before coloring.
  SmallVector<Align, 16> OrigAlignments;

  // OrigSizes - Sizes of stack objects before coloring.
  SmallVector<unsigned, 16> OrigSizes;

  // AllColors - If index is set, it's a spill slot, i.e. color.
  // FIXME: This assumes PEI locate spill slot with smaller indices
  // closest to stack pointer / frame pointer. Therefore, smaller
  // index == better color. This is per stack ID.
  SmallVector<BitVector, 2> AllColors;

  // NextColor - Next "color" that's not yet used. This is per stack ID.
  SmallVector<int, 2> NextColors = {-1};

  // UsedColors - "Colors" that have been assigned. This is per stack ID
  SmallVector<BitVector, 2> UsedColors;

  // Join all intervals sharing one color into a single LiveIntervalUnion to
  // speedup range overlap test.
  class ColorAssignmentInfo {
    // Single liverange (used to avoid creation of LiveIntervalUnion).
    LiveInterval *SingleLI = nullptr;
    // LiveIntervalUnion to perform overlap test.
    LiveIntervalUnion *LIU = nullptr;
    // LiveIntervalUnion has a parameter in its constructor so doing this
    // dirty magic.
    uint8_t LIUPad[sizeof(LiveIntervalUnion)];

  public:
    ~ColorAssignmentInfo() {
      if (LIU)
        LIU->~LiveIntervalUnion(); // Dirty magic again.
    }

    // Return true if LiveInterval overlaps with any
    // intervals that have already been assigned to this color.
    bool overlaps(LiveInterval *LI) const {
      if (LIU)
        return LiveIntervalUnion::Query(*LI, *LIU).checkInterference();
      return SingleLI ? SingleLI->overlaps(*LI) : false;
    }

    // Add new LiveInterval to this color.
    void add(LiveInterval *LI, LiveIntervalUnion::Allocator &Alloc) {
      assert(!overlaps(LI));
      if (LIU) {
        LIU->unify(*LI, *LI);
      } else if (SingleLI) {
        LIU = new (LIUPad) LiveIntervalUnion(Alloc);
        LIU->unify(*SingleLI, *SingleLI);
        LIU->unify(*LI, *LI);
        SingleLI = nullptr;
      } else
        SingleLI = LI;
    }
  };

  LiveIntervalUnion::Allocator LIUAlloc;

  // Assignments - Color to intervals mapping.
  SmallVector<ColorAssignmentInfo, 16> Assignments;

public:
  StackSlotColoring(MachineFunction &MF, LiveStacks *LS,
                    MachineBlockFrequencyInfo *MBFI, SlotIndexes *Indexes)
      : MFI(&MF.getFrameInfo()), TII(MF.getSubtarget().getInstrInfo()), LS(LS),
        MBFI(MBFI), Indexes(Indexes) {}
  bool run(MachineFunction &MF);

private:
  void InitializeSlots();
  void ScanForSpillSlotRefs(MachineFunction &MF);
  int ColorSlot(LiveInterval *li);
  bool ColorSlots(MachineFunction &MF);
  void RewriteInstruction(MachineInstr &MI, SmallVectorImpl<int> &SlotMapping,
                          MachineFunction &MF);
  bool RemoveDeadStores(MachineBasicBlock *MBB);
};

class StackSlotColoringLegacy : public MachineFunctionPass {
public:
  static char ID; // Pass identification

  StackSlotColoringLegacy() : MachineFunctionPass(ID) {
    initializeStackSlotColoringLegacyPass(*PassRegistry::getPassRegistry());
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addRequired<SlotIndexesWrapperPass>();
    AU.addPreserved<SlotIndexesWrapperPass>();
    AU.addRequired<LiveStacksWrapperLegacy>();
    AU.addRequired<MachineBlockFrequencyInfoWrapperPass>();
    AU.addPreserved<MachineBlockFrequencyInfoWrapperPass>();
    AU.addPreservedID(MachineDominatorsID);

    // In some Target's pipeline, register allocation (RA) might be
    // split into multiple phases based on register class. So, this pass
    // may be invoked multiple times requiring it to save these analyses to be
    // used by RA later.
    AU.addPreserved<LiveIntervalsWrapperPass>();
    AU.addPreserved<LiveDebugVariablesWrapperLegacy>();

    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

} // end anonymous namespace

char StackSlotColoringLegacy::ID = 0;

char &llvm::StackSlotColoringID = StackSlotColoringLegacy::ID;

INITIALIZE_PASS_BEGIN(StackSlotColoringLegacy, DEBUG_TYPE,
                      "Stack Slot Coloring", false, false)
INITIALIZE_PASS_DEPENDENCY(SlotIndexesWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LiveStacksWrapperLegacy)
INITIALIZE_PASS_DEPENDENCY(MachineLoopInfoWrapperPass)
INITIALIZE_PASS_END(StackSlotColoringLegacy, DEBUG_TYPE, "Stack Slot Coloring",
                    false, false)

namespace {

// IntervalSorter - Comparison predicate that sort live intervals by
// their weight.
struct IntervalSorter {
  bool operator()(LiveInterval* LHS, LiveInterval* RHS) const {
    return LHS->weight() > RHS->weight();
  }
};

} // end anonymous namespace

/// ScanForSpillSlotRefs - Scan all the machine instructions for spill slot
/// references and update spill slot weights.
void StackSlotColoring::ScanForSpillSlotRefs(MachineFunction &MF) {
  SSRefs.resize(MFI->getObjectIndexEnd());

  // FIXME: Need the equivalent of MachineRegisterInfo for frameindex operands.
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : MBB) {
      for (const MachineOperand &MO : MI.operands()) {
        if (!MO.isFI())
          continue;
        int FI = MO.getIndex();
        if (FI < 0)
          continue;
        if (!LS->hasInterval(FI))
          continue;
        LiveInterval &li = LS->getInterval(FI);
        if (!MI.isDebugInstr())
          li.incrementWeight(
              LiveIntervals::getSpillWeight(false, true, MBFI, MI));
      }
      for (MachineMemOperand *MMO : MI.memoperands()) {
        if (const FixedStackPseudoSourceValue *FSV =
                dyn_cast_or_null<FixedStackPseudoSourceValue>(
                    MMO->getPseudoValue())) {
          int FI = FSV->getFrameIndex();
          if (FI >= 0)
            SSRefs[FI].push_back(MMO);
        }
      }
    }
  }
}

/// InitializeSlots - Process all spill stack slot liveintervals and add them
/// to a sorted (by weight) list.
void StackSlotColoring::InitializeSlots() {
  int LastFI = MFI->getObjectIndexEnd();

  // There is always at least one stack ID.
  AllColors.resize(1);
  UsedColors.resize(1);

  OrigAlignments.resize(LastFI);
  OrigSizes.resize(LastFI);
  AllColors[0].resize(LastFI);
  UsedColors[0].resize(LastFI);
  Assignments.resize(LastFI);

  using Pair = std::iterator_traits<LiveStacks::iterator>::value_type;

  SmallVector<Pair *, 16> Intervals;

  Intervals.reserve(LS->getNumIntervals());
  for (auto &I : *LS)
    Intervals.push_back(&I);
  llvm::sort(Intervals,
             [](Pair *LHS, Pair *RHS) { return LHS->first < RHS->first; });

  // Gather all spill slots into a list.
  LLVM_DEBUG(dbgs() << "Spill slot intervals:\n");
  for (auto *I : Intervals) {
    LiveInterval &li = I->second;
    LLVM_DEBUG(li.dump());
    int FI = li.reg().stackSlotIndex();
    if (MFI->isDeadObjectIndex(FI))
      continue;

    SSIntervals.push_back(&li);
    OrigAlignments[FI] = MFI->getObjectAlign(FI);
    OrigSizes[FI]      = MFI->getObjectSize(FI);

    auto StackID = MFI->getStackID(FI);
    if (StackID != 0) {
      AllColors.resize(StackID + 1);
      UsedColors.resize(StackID + 1);
      AllColors[StackID].resize(LastFI);
      UsedColors[StackID].resize(LastFI);
    }

    AllColors[StackID].set(FI);
  }
  LLVM_DEBUG(dbgs() << '\n');

  // Sort them by weight.
  llvm::stable_sort(SSIntervals, IntervalSorter());

  NextColors.resize(AllColors.size());

  // Get first "color".
  for (unsigned I = 0, E = AllColors.size(); I != E; ++I)
    NextColors[I] = AllColors[I].find_first();
}

/// ColorSlot - Assign a "color" (stack slot) to the specified stack slot.
int StackSlotColoring::ColorSlot(LiveInterval *li) {
  int Color = -1;
  bool Share = false;
  int FI = li->reg().stackSlotIndex();
  uint8_t StackID = MFI->getStackID(FI);

  if (!DisableSharing) {

    // Check if it's possible to reuse any of the used colors.
    Color = UsedColors[StackID].find_first();
    while (Color != -1) {
      if (!Assignments[Color].overlaps(li)) {
        Share = true;
        ++NumEliminated;
        break;
      }
      Color = UsedColors[StackID].find_next(Color);
    }
  }

  if (Color != -1 && MFI->getStackID(Color) != MFI->getStackID(FI)) {
    LLVM_DEBUG(dbgs() << "cannot share FIs with different stack IDs\n");
    Share = false;
  }

  // Assign it to the first available color (assumed to be the best) if it's
  // not possible to share a used color with other objects.
  if (!Share) {
    assert(NextColors[StackID] != -1 && "No more spill slots?");
    Color = NextColors[StackID];
    UsedColors[StackID].set(Color);
    NextColors[StackID] = AllColors[StackID].find_next(NextColors[StackID]);
  }

  assert(MFI->getStackID(Color) == MFI->getStackID(FI));

  // Record the assignment.
  Assignments[Color].add(li, LIUAlloc);
  LLVM_DEBUG(dbgs() << "Assigning fi#" << FI << " to fi#" << Color << "\n");

  // Change size and alignment of the allocated slot. If there are multiple
  // objects sharing the same slot, then make sure the size and alignment
  // are large enough for all.
  Align Alignment = OrigAlignments[FI];
  if (!Share || Alignment > MFI->getObjectAlign(Color))
    MFI->setObjectAlignment(Color, Alignment);
  int64_t Size = OrigSizes[FI];
  if (!Share || Size > MFI->getObjectSize(Color))
    MFI->setObjectSize(Color, Size);
  return Color;
}

/// Colorslots - Color all spill stack slots and rewrite all frameindex machine
/// operands in the function.
bool StackSlotColoring::ColorSlots(MachineFunction &MF) {
  unsigned NumObjs = MFI->getObjectIndexEnd();
  SmallVector<int, 16> SlotMapping(NumObjs, -1);
  SmallVector<float, 16> SlotWeights(NumObjs, 0.0);
  SmallVector<SmallVector<int, 4>, 16> RevMap(NumObjs);
  BitVector UsedColors(NumObjs);

  LLVM_DEBUG(dbgs() << "Color spill slot intervals:\n");
  bool Changed = false;
  for (LiveInterval *li : SSIntervals) {
    int SS = li->reg().stackSlotIndex();
    int NewSS = ColorSlot(li);
    assert(NewSS >= 0 && "Stack coloring failed?");
    SlotMapping[SS] = NewSS;
    RevMap[NewSS].push_back(SS);
    SlotWeights[NewSS] += li->weight();
    UsedColors.set(NewSS);
    Changed |= (SS != NewSS);
  }

  LLVM_DEBUG(dbgs() << "\nSpill slots after coloring:\n");
  for (LiveInterval *li : SSIntervals) {
    int SS = li->reg().stackSlotIndex();
    li->setWeight(SlotWeights[SS]);
  }
  // Sort them by new weight.
  llvm::stable_sort(SSIntervals, IntervalSorter());

#ifndef NDEBUG
  for (LiveInterval *li : SSIntervals)
    LLVM_DEBUG(li->dump());
  LLVM_DEBUG(dbgs() << '\n');
#endif

  if (!Changed)
    return false;

  // Rewrite all MachineMemOperands.
  for (unsigned SS = 0, SE = SSRefs.size(); SS != SE; ++SS) {
    int NewFI = SlotMapping[SS];
    if (NewFI == -1 || (NewFI == (int)SS))
      continue;

    const PseudoSourceValue *NewSV = MF.getPSVManager().getFixedStack(NewFI);
    SmallVectorImpl<MachineMemOperand *> &RefMMOs = SSRefs[SS];
    for (MachineMemOperand *MMO : RefMMOs)
      MMO->setValue(NewSV);
  }

  // Rewrite all MO_FrameIndex operands.  Look for dead stores.
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : MBB)
      RewriteInstruction(MI, SlotMapping, MF);
    RemoveDeadStores(&MBB);
  }

  // Delete unused stack slots.
  for (int StackID = 0, E = AllColors.size(); StackID != E; ++StackID) {
    int NextColor = NextColors[StackID];
    while (NextColor != -1) {
      LLVM_DEBUG(dbgs() << "Removing unused stack object fi#" << NextColor << "\n");
      MFI->RemoveStackObject(NextColor);
      NextColor = AllColors[StackID].find_next(NextColor);
    }
  }

  return true;
}

/// RewriteInstruction - Rewrite specified instruction by replacing references
/// to old frame index with new one.
void StackSlotColoring::RewriteInstruction(MachineInstr &MI,
                                           SmallVectorImpl<int> &SlotMapping,
                                           MachineFunction &MF) {
  // Update the operands.
  for (MachineOperand &MO : MI.operands()) {
    if (!MO.isFI())
      continue;
    int OldFI = MO.getIndex();
    if (OldFI < 0)
      continue;
    int NewFI = SlotMapping[OldFI];
    if (NewFI == -1 || NewFI == OldFI)
      continue;

    assert(MFI->getStackID(OldFI) == MFI->getStackID(NewFI));
    MO.setIndex(NewFI);
  }

  // The MachineMemOperands have already been updated.
}

/// RemoveDeadStores - Scan through a basic block and look for loads followed
/// by stores.  If they're both using the same stack slot, then the store is
/// definitely dead.  This could obviously be much more aggressive (consider
/// pairs with instructions between them), but such extensions might have a
/// considerable compile time impact.
bool StackSlotColoring::RemoveDeadStores(MachineBasicBlock* MBB) {
  // FIXME: This could be much more aggressive, but we need to investigate
  // the compile time impact of doing so.
  bool changed = false;

  SmallVector<MachineInstr*, 4> toErase;

  for (MachineBasicBlock::iterator I = MBB->begin(), E = MBB->end();
       I != E; ++I) {
    if (DCELimit != -1 && (int)NumDead >= DCELimit)
      break;
    int FirstSS, SecondSS;
    if (TII->isStackSlotCopy(*I, FirstSS, SecondSS) && FirstSS == SecondSS &&
        FirstSS != -1) {
      ++NumDead;
      changed = true;
      toErase.push_back(&*I);
      continue;
    }

    MachineBasicBlock::iterator NextMI = std::next(I);
    MachineBasicBlock::iterator ProbableLoadMI = I;

    Register LoadReg;
    Register StoreReg;
    TypeSize LoadSize = TypeSize::getZero();
    TypeSize StoreSize = TypeSize::getZero();
    if (!(LoadReg = TII->isLoadFromStackSlot(*I, FirstSS, LoadSize)))
      continue;
    // Skip the ...pseudo debugging... instructions between a load and store.
    while ((NextMI != E) && NextMI->isDebugInstr()) {
      ++NextMI;
      ++I;
    }
    if (NextMI == E) continue;
    if (!(StoreReg = TII->isStoreToStackSlot(*NextMI, SecondSS, StoreSize)))
      continue;
    if (FirstSS != SecondSS || LoadReg != StoreReg || FirstSS == -1 ||
        LoadSize != StoreSize || !MFI->isSpillSlotObjectIndex(FirstSS))
      continue;

    ++NumDead;
    changed = true;

    if (NextMI->findRegisterUseOperandIdx(LoadReg, /*TRI=*/nullptr, true) !=
        -1) {
      ++NumDead;
      toErase.push_back(&*ProbableLoadMI);
    }

    toErase.push_back(&*NextMI);
    ++I;
  }

  for (MachineInstr *MI : toErase) {
    if (Indexes)
      Indexes->removeMachineInstrFromMaps(*MI);
    MI->eraseFromParent();
  }

  return changed;
}

bool StackSlotColoring::run(MachineFunction &MF) {
  LLVM_DEBUG({
    dbgs() << "********** Stack Slot Coloring **********\n"
           << "********** Function: " << MF.getName() << '\n';
  });

  bool Changed = false;

  unsigned NumSlots = LS->getNumIntervals();
  if (NumSlots == 0)
    // Nothing to do!
    return false;

  // If there are calls to setjmp or sigsetjmp, don't perform stack slot
  // coloring. The stack could be modified before the longjmp is executed,
  // resulting in the wrong value being used afterwards.
  if (MF.exposesReturnsTwice())
    return false;

  // Gather spill slot references
  ScanForSpillSlotRefs(MF);
  InitializeSlots();
  Changed = ColorSlots(MF);

  for (int &Next : NextColors)
    Next = -1;

  SSIntervals.clear();
  for (auto &RefMMOs : SSRefs)
    RefMMOs.clear();
  SSRefs.clear();
  OrigAlignments.clear();
  OrigSizes.clear();
  AllColors.clear();
  UsedColors.clear();
  Assignments.clear();

  return Changed;
}

bool StackSlotColoringLegacy::runOnMachineFunction(MachineFunction &MF) {
  if (skipFunction(MF.getFunction()))
    return false;

  LiveStacks *LS = &getAnalysis<LiveStacksWrapperLegacy>().getLS();
  MachineBlockFrequencyInfo *MBFI =
      &getAnalysis<MachineBlockFrequencyInfoWrapperPass>().getMBFI();
  SlotIndexes *Indexes = &getAnalysis<SlotIndexesWrapperPass>().getSI();
  StackSlotColoring Impl(MF, LS, MBFI, Indexes);
  return Impl.run(MF);
}

PreservedAnalyses
StackSlotColoringPass::run(MachineFunction &MF,
                           MachineFunctionAnalysisManager &MFAM) {
  LiveStacks *LS = &MFAM.getResult<LiveStacksAnalysis>(MF);
  MachineBlockFrequencyInfo *MBFI =
      &MFAM.getResult<MachineBlockFrequencyAnalysis>(MF);
  SlotIndexes *Indexes = &MFAM.getResult<SlotIndexesAnalysis>(MF);
  StackSlotColoring Impl(MF, LS, MBFI, Indexes);
  bool Changed = Impl.run(MF);
  if (!Changed)
    return PreservedAnalyses::all();

  auto PA = getMachineFunctionPassPreservedAnalyses();
  PA.preserveSet<CFGAnalyses>();
  PA.preserve<SlotIndexesAnalysis>();
  PA.preserve<MachineBlockFrequencyAnalysis>();
  PA.preserve<MachineDominatorTreeAnalysis>();
  PA.preserve<LiveIntervalsAnalysis>();
  PA.preserve<LiveDebugVariablesAnalysis>();
  return PA;
}
