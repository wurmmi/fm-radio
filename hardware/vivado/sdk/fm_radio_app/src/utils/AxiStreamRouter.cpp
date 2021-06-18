/**
 * @file    AxiStreamRouter.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AxiStreamRouter.h"

using namespace std;

AxiStreamRouter::AxiStreamRouter() {}

AxiStreamRouter::~AxiStreamRouter() {}

void AxiStreamRouter::ConfigureAxiSwitch(u8 parallel_ip_nr) {
  // Clear all existing configurations
  XAxisScr_MiPortDisableAll(&mAxisSwitchInInst);
  XAxisScr_RegUpdateEnable(&mAxisSwitchInInst);
  XAxisScr_MiPortDisableAll(&mAxisSwitchOutInst);
  XAxisScr_RegUpdateEnable(&mAxisSwitchOutInst);

  // Set new configurations
  uint32_t from_src = 0;
  uint32_t to_dest  = parallel_ip_nr;
  XAxisScr_MiPortEnable(&mAxisSwitchInInst, to_dest, from_src);
  XAxisScr_RegUpdateEnable(&mAxisSwitchInInst);
  from_src = parallel_ip_nr;
  to_dest  = 0;
  XAxisScr_MiPortEnable(&mAxisSwitchOutInst, to_dest, from_src);
  XAxisScr_RegUpdateEnable(&mAxisSwitchOutInst);
}

void AxiStreamRouter::SelectIP(IPSelection selection) {
  ConfigureAxiSwitch(static_cast<uint8_t>(selection));
  currentSelection = selection;
}

IPSelection AxiStreamRouter::GetCurrentlySelectedIP() {
  return mCurrentSelection;
}
