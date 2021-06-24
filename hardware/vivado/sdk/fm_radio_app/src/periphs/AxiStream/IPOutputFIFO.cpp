/**
 * @file    IPOutputFIFO.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "IPOutputFIFO.h"

#include <iostream>

#include "log.h"

using namespace std;

IPOutputFIFO::IPOutputFIFO(uint32_t device_id) : FIFO(device_id) {}

IPOutputFIFO::~IPOutputFIFO() {}

vector<uint32_t> IPOutputFIFO::ReadAll() {
  LOG_INFO("Reading data from IPOutputFIFO ...");
  /**
   * TODO:
   *  Read all data from Rx FIFO and store into vector
   *
   */
  return {};
}
