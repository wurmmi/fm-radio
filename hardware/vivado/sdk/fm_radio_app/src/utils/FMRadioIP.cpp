/**
 * @file    FMRadioIP.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FMRadioIP.h"

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

FMRadioIP::FMRadioIP(uint32_t device_id) : mDeviceId(device_id) {}

FMRadioIP::~FMRadioIP() {}

/**
 * @brief Convert number to string in hex-format
 * @return string
 */
string FMRadioIP::UintToHexString(uint64_t num) const {
  stringstream ss;
  ss << hex << num;
  return string(ss.str());
}

void FMRadioIP::PrintInfo() {
  printf("     build date :  %s\n", GetBuildTime().c_str());
  printf("     git hash   :  %s\n", GetGitHash().c_str());
}
