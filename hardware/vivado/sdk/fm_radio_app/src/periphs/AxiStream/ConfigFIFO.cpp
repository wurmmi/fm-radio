/**
 * @file    ConfigFIFO.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "ConfigFIFO.h"

#include <iostream>

#include "ADAU1761_hw.h"

using namespace std;

ConfigFIFO::ConfigFIFO(uint32_t device_id) : FIFO(device_id) {}

ConfigFIFO::~ConfigFIFO() {}

uint8_t ConfigFIFO::read(uint16_t addr) {
  // Write bytes to transfer into Tx FIFO
  XLlFifo_TxPutWord(
      &mDev, ((ADAU1761_SPI_CHIP_ADDR << 1) | ADAU1761_SPI_READ_CMD) & 0xFF);
  XLlFifo_TxPutWord(&mDev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(&mDev, addr & 0xFF);
  XLlFifo_TxPutWord(&mDev, 0);

  // Begin transfer
  XLlFifo_iTxSetLen(&mDev, 4 * FIFO_WORDSIZE);

  // Wait for connected audio codec to respond into the Rx FIFO
  while (XLlFifo_RxOccupancy(&mDev) != 4) {
  }

  // Read response
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  uint32_t rdata = XLlFifo_RxGetWord(&mDev);

  return (uint8_t)(rdata & 0xFF);
}

void ConfigFIFO::write(uint16_t addr, uint8_t value) {
  // Write bytes to transfer into Tx FIFO
  XLlFifo_TxPutWord(&mDev, (ADAU1761_SPI_CHIP_ADDR << 1) & 0xFF);
  XLlFifo_TxPutWord(&mDev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(&mDev, addr & 0xFF);
  XLlFifo_TxPutWord(&mDev, value);

  // Begin transfer
  XLlFifo_iTxSetLen(&mDev, 4 * FIFO_WORDSIZE);

  // Wait for connected audio codec to respond into the Rx FIFO
  while (XLlFifo_RxOccupancy(&mDev) != 4) {
  }

  // Read response
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
}
