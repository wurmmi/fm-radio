/**
 * @file    FMRadioIP_HLS.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FMRadioIP_HLS.h"

#include <chrono>
#include <iostream>

/** NOTE:
 *  This is a workaround for a bug in the Xilinx SDK standard libraries.
 *  https://stackoverflow.com/a/49389145
 */
#undef str
#include <sstream>

#include "log.h"

using namespace std;

FMRadioIP_HLS::FMRadioIP_HLS(uint32_t device_id) : FMRadioIP(device_id) {
  Initialize();
}

FMRadioIP_HLS::~FMRadioIP_HLS() {}

bool FMRadioIP_HLS::Initialize() {
  int status = XFm_receiver_hls_Initialize(&mDev, mDeviceId);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Could not initialize FM Receiver IP");
    return false;
  }

  return true;
}

void FMRadioIP_HLS::LED_SetOn(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_config_led_ctrl_V(&mDev);

  state |= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0xFF;

  XFm_receiver_hls_Set_config_led_ctrl_V(&mDev, state);
}

void FMRadioIP_HLS::LED_Toggle(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_config_led_ctrl_V(&mDev);

  state ^= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state ^= 0xFF;

  XFm_receiver_hls_Set_config_led_ctrl_V(&mDev, state);
}

void FMRadioIP_HLS::LED_SetOff(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_config_led_ctrl_V(&mDev);

  state &= ~(1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0x0;

  XFm_receiver_hls_Set_config_led_ctrl_V(&mDev, state);
}

void FMRadioIP_HLS::PrintInfo() {
  printf(" -- HLS:\n");
  FMRadioIP::PrintInfo();
}

string FMRadioIP_HLS::GetGitHash() {
  auto git_hash = XFm_receiver_hls_Get_status_git_hash_V(&mDev);

  return UintToHexString(git_hash);
}

string FMRadioIP_HLS::GetBuildTime() {
  uint64_t build_datetime_int = XFm_receiver_hls_Get_status_build_time_V(&mDev);

  // Convert to string
  string build_time = DatetimeToString(build_datetime_int);

  return build_time;
}

void FMRadioIP_HLS::SetMode(TMode mode) {
  XFm_receiver_hls_Set_config_enable_fm_radio_ip(&mDev,
                                                 static_cast<uint32_t>(mode));
}

TMode FMRadioIP_HLS::GetMode() {
  auto mode = XFm_receiver_hls_Get_config_enable_fm_radio_ip(&mDev);

  return static_cast<TMode>(mode);
}
