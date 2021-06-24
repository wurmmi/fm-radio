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
  uint32_t available_values  = XLlFifo_iRxGetLen(&mDev) / 4;
  uint32_t available_values2 = XLlFifo_iRxOccupancy(&mDev);
  LOG_INFO("available_values  (iRxGetLen)   : %d", available_values);
  LOG_INFO("available_values2 (iRxOccupancy): %d", available_values2);

  for (uint32_t i = 0; i < available_values; i++) {
    value = XLlFifo_RxGetWord(&mDev);
    data.emplace_back(value);

    // if (XLlFifo_iRxOccupancy(&mDev)) {
    //  RxWord = XLlFifo_RxGetWord(&mDev);
    //}
  }

  //  while (XLlFifo_RxOccupancy(&mDev) > 1) {  // NOTE: option 1
  //    // while(!XLlFifo_IsRxEmpty()) {        // NOTE: option 2
  //    value = XLlFifo_RxGetWord(&mDev);
  //    data.emplace_back(value);
  //  }

  return data;
}

void IPOutputFIFO::ResetRx() {
  LOG_INFO("reset IPOutputFIFO Rx");
  XLlFifo_RxReset(&mDev);

  LOG_INFO("reset IPOutputFIFO Total");
  XLlFifo_Reset(&mDev);
}
