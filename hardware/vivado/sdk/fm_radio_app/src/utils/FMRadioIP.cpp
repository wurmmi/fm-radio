/**
 * @file    FMRadioIP.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FMRadioIP.h"

#include <time.h>

#include <chrono>
#include <iostream>

#include "log.h"

using namespace std;

FMRadioIP::FMRadioIP(uint32_t device_id) : mDeviceId(device_id) {
  Initialize();
}

FMRadioIP::~FMRadioIP() {}

bool FMRadioIP::Initialize() {
  int status = XFm_receiver_hls_Initialize(&mDev, mDeviceId);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Could not initialize FM Receiver IP");
    return false;
  }

  return true;
}

void FMRadioIP::LED_SetOn(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_led_ctrl(&mDev);

  state |= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0xFF;

  XFm_receiver_hls_Set_led_ctrl(&mDev, state);
}

void FMRadioIP::LED_Toggle(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_led_ctrl(&mDev);

  state ^= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state ^= 0xFF;

  XFm_receiver_hls_Set_led_ctrl(&mDev, state);
}

void FMRadioIP::LED_SetOff(TLed led) {
  uint32_t state = XFm_receiver_hls_Get_led_ctrl(&mDev);

  state &= ~(1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0x0;

  XFm_receiver_hls_Set_led_ctrl(&mDev, state);
}

std::string FMRadioIP::GetGitHash() {
  uint8_t const length  = XFM_RECEIVER_HLS_CONFIG_DEPTH_GIT_HASH;
  char git_hash[length] = {0};

  int num_read =
      XFm_receiver_hls_Read_git_hash_Bytes(&mDev, 0, git_hash, length);
  if (num_read != length) {
    LOG_ERROR("Could not read git_hash bytes");
    return "failed";
  }

  return string(git_hash);
}

std::string FMRadioIP::GetBuildTime() {
  uint8_t const length    = XFM_RECEIVER_HLS_CONFIG_DEPTH_BUILD_TIME;
  char build_time[length] = {0};

  int num_read =
      XFm_receiver_hls_Read_build_time_Bytes(&mDev, 0, build_time, length);
  if (num_read != length) {
    LOG_ERROR("Could not read build_time bytes");
    return "failed";
  }

  // Convert to human-readable date string
  // NOTE: I'm sure there's a much better way to do this...  :)
  string year  = "20" + string{build_time[0], build_time[1]};
  string month = string{build_time[2], build_time[3]};
  string day   = string{build_time[4], build_time[5]};

  string hour = string{build_time[6], build_time[7]};
  string min  = string{build_time[8], build_time[9]};
  string sec  = string{build_time[10], build_time[11]};

  string date =
      month + "/" + day + "/" + year + " " + hour + ":" + min + ":" + sec;

  return date;
}
