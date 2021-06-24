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

  // Read all data from Rx FIFO and store into vector
  vector<uint32_t> data;
  uint32_t value;
  uint32_t available_values = XLlFifo_RxOccupancy(&mDev);
  LOG_INFO("available_values: %d", available_values);

  auto ReceiveLength = (XLlFifo_iRxGetLen(&mDev)) / 4;
  for (uint32_t i = 0; i < ReceiveLength; i++) {
    uint32_t RxWord = XLlFifo_RxGetWord(&mDev);
    // ********
    // do something here with the data
    // ********
    if (XLlFifo_iRxOccupancy(&mDev)) {
      RxWord = XLlFifo_RxGetWord(&mDev);
    }
  }
  while (XLlFifo_RxOccupancy(&mDev) > 1) {  // NOTE: option 1
    // while(!XLlFifo_IsRxEmpty()) {        // NOTE: option 2
    value = XLlFifo_RxGetWord(&mDev);
    data.emplace_back(value);
  }

  return data;
}
