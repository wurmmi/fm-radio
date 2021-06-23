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

/**
 * @brief Convert to human-readable date string
 *        NOTE: I'm sure there's a much better way to do this...  :)
 *        Example build_time result:
 *           yymmddhhmmss
 *           210609184711 --> 2021/06/09 18:47:11
 * @param datetime_int
 * @return std::string
 */
std::string FMRadioIP::DatetimeToString(uint64_t datetime_int) const {
  string build_time = UintToHexString(datetime_int);

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

void FMRadioIP::PrintInfo() {
  printf("     build date :  %s\n", GetBuildTime().c_str());
  printf("     git hash   :  %s\n", GetGitHash().c_str());
}
