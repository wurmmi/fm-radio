/**
 * @file    FMRadioIP_VHDL.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FMRadioIP_VHDL.h"

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

FMRadioIP_VHDL::FMRadioIP_VHDL(uint32_t device_id) : FMRadioIP(device_id) {
  Initialize();
}

FMRadioIP_VHDL::~FMRadioIP_VHDL() {}

bool FMRadioIP_VHDL::Initialize() {
  int status = XFm_receiver_hls_Initialize(&mDev, mDeviceId);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Could not initialize FM Receiver IP");
    return false;
  }

  return true;
}

void FMRadioIP_VHDL::LED_SetOn(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_config_led_ctrl_V(&mDev);

  state |= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0xFF;

  XFm_receiver_hls_Set_config_led_ctrl_V(&mDev, state);
}

void FMRadioIP_VHDL::LED_Toggle(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_config_led_ctrl_V(&mDev);

  state ^= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state ^= 0xFF;

  XFm_receiver_hls_Set_config_led_ctrl_V(&mDev, state);
}

void FMRadioIP_VHDL::LED_SetOff(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_config_led_ctrl_V(&mDev);

  state &= ~(1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0x0;

  XFm_receiver_hls_Set_config_led_ctrl_V(&mDev, state);
}

string FMRadioIP_VHDL::GetGitHash() {
  auto git_hash = XFm_receiver_hls_Get_status_git_hash_V(&mDev);

  return UintToHexString(git_hash);
}

string FMRadioIP_VHDL::GetBuildTime() {
  auto build_time_uint = XFm_receiver_hls_Get_status_build_time_V(&mDev);

  // Convert to human-readable date string
  // NOTE: I'm sure there's a much better way to do this...  :)
  // Example build_time result:
  //    yymmddhhmmss
  //    210609184711 --> 2021/06/09 18:47:11
  string build_time = UintToHexString(build_time_uint);

  // Sanity check
  uint8_t const expected_length_c = 12;
  uint8_t len                     = build_time.length();
  if (len < expected_length_c) {
    LOG_ERROR(
        "build_time does not match expected length! (is: %d, expected: %d)",
        len,
        expected_length_c);
    return "error";
  }

  // Date formatting
  build_time.insert(10, 1, ':');
  build_time.insert(8, 1, ':');
  build_time.insert(6, 1, ' ');
  build_time.insert(4, 1, '/');
  build_time.insert(2, 1, '/');
  build_time.insert(0, "20");

  return build_time;
}

void FMRadioIP_VHDL::SetMode(TMode mode) {
  XFm_receiver_hls_Set_config_enable_fm_radio_ip(&mDev,
                                                 static_cast<uint32_t>(mode));
}

TMode FMRadioIP_VHDL::GetMode() {
  auto mode = XFm_receiver_hls_Get_config_enable_fm_radio_ip(&mDev);

  return static_cast<TMode>(mode);
}
