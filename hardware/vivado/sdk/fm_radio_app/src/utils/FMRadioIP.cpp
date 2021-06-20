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

FMRadioIP::FMRadioIP(uint32_t device_id) : mDeviceId(device_id) {
  Initialize();
}

FMRadioIP::~FMRadioIP() {}
