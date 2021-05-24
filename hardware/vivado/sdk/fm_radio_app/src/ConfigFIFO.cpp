/**
 * @file    ConfigFIFO.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "ConfigFIFO.h"

#include <iostream>

using namespace std;

ConfigFIFO::ConfigFIFO(uint32_t device_id) : FIFO(device_id) {}

ConfigFIFO::~ConfigFIFO() {}

uint8_t ConfigFIFO::read(uint16_t addr) {
  XLlFifo_TxPutWord(&mDev, ((FIFO_CHIP_ADDR << 1) | 0x01) & 0xFF);
  XLlFifo_TxPutWord(&mDev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(&mDev, addr & 0xFF);
  XLlFifo_TxPutWord(&mDev, 0);
  XLlFifo_iTxSetLen(&mDev, 4 * FIFO_WORDSIZE);
 // while (XLlFifo_RxOccupancy(&mDev) != 4) {
 // }
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  uint32_t rdata = XLlFifo_RxGetWord(&mDev);

  return (uint8_t)(rdata & 0xFF);
}

void ConfigFIFO::write(uint16_t addr, uint8_t value) {
  XLlFifo_TxPutWord(&mDev, (FIFO_CHIP_ADDR << 1) & 0xFF);
  XLlFifo_TxPutWord(&mDev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(&mDev, addr & 0xFF);
  XLlFifo_TxPutWord(&mDev, value);
  XLlFifo_iTxSetLen(&mDev, 4 * FIFO_WORDSIZE);
  //while (XLlFifo_RxOccupancy(&mDev) != 4) {
 // }
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
  XLlFifo_RxGetWord(&mDev);
}
