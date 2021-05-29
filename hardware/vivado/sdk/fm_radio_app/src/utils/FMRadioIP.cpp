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
