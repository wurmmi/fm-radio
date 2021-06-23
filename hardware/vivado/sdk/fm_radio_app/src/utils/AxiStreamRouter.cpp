/**
 * @file    AxiStreamRouter.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "AxiStreamRouter.h"

#include "log.h"

using namespace std;

AxiStreamRouter::AxiStreamRouter() {
  Initialize();
  SelectIP(IPSelection::HLS);
}

AxiStreamRouter::~AxiStreamRouter() {}

bool AxiStreamRouter::Initialize() {
  /* Input selector switch */
  XAxis_Switch_Config* cfgPtr =
      XAxisScr_LookupConfig(XPAR_AXIS_SWITCH_IN_DEVICE_ID);
  if (cfgPtr == nullptr) {
    LOG_ERROR("AxisSwitchIn not found!");
    return false;
  }
  uint32_t status =
      XAxisScr_CfgInitialize(&mAxisSwitchIn, cfgPtr, cfgPtr->BaseAddress);
  if (status != XST_SUCCESS) {
    LOG_ERROR("AxisSwitchIn initialization failed (error %ld)", status);
    return false;
  }

  /* Output selector switch */
  cfgPtr = XAxisScr_LookupConfig(XPAR_AXIS_SWITCH_OUT_DEVICE_ID);
  if (cfgPtr == nullptr) {
    LOG_ERROR("AxisSwitchOut not found!");
    return false;
  }
  status = XAxisScr_CfgInitialize(&mAxisSwitchOut, cfgPtr, cfgPtr->BaseAddress);
  if (status != XST_SUCCESS) {
    LOG_ERROR("AxisSwitchOut initialization failed (error %ld)", status);
    return false;
  }

  return true;
}

void AxiStreamRouter::ConfigureAxiSwitch(uint8_t parallel_ip_nr) {
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
  switch (selection) {
    case IPSelection::HLS:
      LOG_INFO("Set AXI stream switches to HLS IP");
      break;
    case IPSelection::VHDL:
      LOG_INFO("Set AXI stream switches to VHDL IP");
      break;
    default:
      LOG_WARN("Unknown IPSelection %d", static_cast<uint8_t>(selection));
      return;
  }

  mCurrentSelection = selection;
  ConfigureAxiSwitch(static_cast<uint8_t>(selection));
}

IPSelection AxiStreamRouter::GetCurrentlySelectedIP() {
  return mCurrentSelection;
}

string AxiStreamRouter::GetCurrentlySelectedIPString() {
  return string(IPSelectionString[static_cast<uint8_t>(mCurrentSelection)]);
}
