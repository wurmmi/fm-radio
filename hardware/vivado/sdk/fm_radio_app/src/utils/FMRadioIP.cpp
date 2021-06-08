/**
 * @file    FMRadioIP.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FMRadioIP.h"

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
  int const length      = 8;
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
  int const length        = 13;
  char build_time[length] = {0};

  int num_read =
      XFm_receiver_hls_Read_build_time_Bytes(&mDev, 0, build_time, length);
  if (num_read != length) {
    LOG_ERROR("Could not read build_time bytes");
    return "failed";
  }

  return string(build_time);
}
