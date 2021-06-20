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
  XAxisScr_MiPortDisableAll(&mAxisSwitchIn);
  XAxisScr_RegUpdateEnable(&mAxisSwitchIn);
  XAxisScr_MiPortDisableAll(&mAxisSwitchOut);
  XAxisScr_RegUpdateEnable(&mAxisSwitchOut);

  // Set new configurations
  uint32_t from_src = 0;
  uint32_t to_dest  = parallel_ip_nr;
  XAxisScr_MiPortEnable(&mAxisSwitchIn, to_dest, from_src);
  XAxisScr_RegUpdateEnable(&mAxisSwitchIn);
  from_src = parallel_ip_nr;
  to_dest  = 0;
  XAxisScr_MiPortEnable(&mAxisSwitchOut, to_dest, from_src);
  XAxisScr_RegUpdateEnable(&mAxisSwitchOut);
}

void AxiStreamRouter::SelectIP(IPSelection selection) {
  ConfigureAxiSwitch(static_cast<uint8_t>(selection));
  mCurrentSelection = selection;
}

IPSelection AxiStreamRouter::GetCurrentlySelectedIP() {
  return mCurrentSelection;
}
