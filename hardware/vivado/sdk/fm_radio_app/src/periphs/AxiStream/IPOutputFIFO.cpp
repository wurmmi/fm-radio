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
  /* Read all data from Rx FIFO and store into vector */
  uint32_t available_values = XLlFifo_RxOccupancy(&mDev);
  // uint32_t available_values_in_packet  = XLlFifo_RxGetLen(&mDev) / 4;
  // LOG_DEBUG("available (RxOccupancy) : %ld", available_values);
  // LOG_DEBUG("available (RxGetLen)    : %ld", available_values_in_packet);

  /** TODO: maybe also current log time into file (once each time)
   *        this could give information about the output speed/timing
   *        --> use FreeRTOS functions:
   *               xTaskGetTickCountFromISR / xTaskGetTickCount
   */
  vector<uint32_t> data;
  uint32_t value;
  for (uint32_t i = 0; i < available_values; i++) {
    value = XLlFifo_RxGetWord(&mDev);
    data.emplace_back(value);
  }

  return data;
}

void IPOutputFIFO::ResetRx() {
  LOG_INFO("Reset IPOutputFIFO");
  XLlFifo_RxReset(&mDev);
  XLlFifo_Reset(&mDev);
  LOG_INFO("Done.");
}
