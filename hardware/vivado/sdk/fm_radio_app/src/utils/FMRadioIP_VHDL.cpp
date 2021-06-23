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

#define IP ((fm_radio_t*)XPAR_FM_RECEIVER_VHDL_0_S_AXI_API_BASEADDR)

FMRadioIP_VHDL::FMRadioIP_VHDL(uint32_t device_id) : FMRadioIP(device_id) {
  Initialize();
}

FMRadioIP_VHDL::~FMRadioIP_VHDL() {}

bool FMRadioIP_VHDL::Initialize() {
  return true;
}

void FMRadioIP_VHDL::LED_SetOn(TLed led) {
  uint32_t state = IP->LED_CONTROL;

  state |= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0xFF;

  IP->LED_CONTROL = state;
}

void FMRadioIP_VHDL::LED_Toggle(TLed led) {
  uint32_t state = IP->LED_CONTROL;

  state ^= (1 << (uint8_t)led);
  if (led == TLed::ALL)
    state ^= 0xFF;

  IP->LED_CONTROL = state;
}

void FMRadioIP_VHDL::LED_SetOff(TLed led) {
  uint32_t state = IP->LED_CONTROL;

  state &= ~(1 << (uint8_t)led);
  if (led == TLed::ALL)
    state = 0x0;

  IP->LED_CONTROL = state;
}

void FMRadioIP_VHDL::PrintInfo() {
  printf(" -- VHDL:\n");
  FMRadioIP::PrintInfo();
}

string FMRadioIP_VHDL::GetGitHash() {
  // Select ROM register address, then read it
  IP->VERSION_ADDR  = 2;
  uint32_t git_hash = IP->VERSION;

  return UintToHexString(git_hash);
}

string FMRadioIP_VHDL::GetBuildTime() {
  // Select ROM register address, then read it
  IP->VERSION_ADDR = 0;
  uint32_t date    = IP->VERSION;
  IP->VERSION_ADDR = 1;
  uint32_t time    = IP->VERSION;

  // Combine to expected format
  uint64_t build_datetime_int = ((uint64_t)date << 24) | time;

  // Convert to string
  string build_time = DatetimeToString(build_datetime_int);

  return build_time;
}

void FMRadioIP_VHDL::SetMode(TMode mode) {
  IP->ENABLE_FM_RADIO = static_cast<uint32_t>(mode);
}

TMode FMRadioIP_VHDL::GetMode() {
  uint32_t mode = IP->ENABLE_FM_RADIO;
  return static_cast<TMode>(mode);
}
