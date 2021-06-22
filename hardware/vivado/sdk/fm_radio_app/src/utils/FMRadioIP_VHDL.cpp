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
  auto git_hash = IP->MAGIC_VALUE;

  return UintToHexString(git_hash);
}

string FMRadioIP_VHDL::GetBuildTime() {
  LOG_ERROR("not implemented yet");
  return "not implemented yet";

  auto build_time_uint = IP->MAGIC_VALUE;

  // Convert to human-readable date string
  // NOTE: I'm sure there's a much better way to do
  // this...  :) Example build_time result:
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
  LOG_ERROR("not implemented yet");

  // IP->MODE = static_cast<uint32_t>(mode);
}

TMode FMRadioIP_VHDL::GetMode() {
  LOG_ERROR("not implemented yet");

  //  auto mode = IP->MODE;
  //  return static_cast<TMode>(mode);
  return TMode::FMRADIO;
}
