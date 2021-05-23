/**
 * @file    adau1761.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "adau1761.h"

#include <iostream>

using namespace std;

adau1761::adau1761() {}

adau1761::~adau1761() {}

uint8_t adau1761::read(uint16_t addr) {
  XLlFifo* dev = &mDevConfig.fifo_spi;

  XLlFifo_TxPutWord(dev, ((mDevConfig.chipAddr << 1) | 0x01) & 0xFF);
  XLlFifo_TxPutWord(dev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(dev, addr & 0xFF);
  XLlFifo_TxPutWord(dev, 0);
  XLlFifo_iTxSetLen(dev, 4 * mDevConfig.wordSize);
  while (XLlFifo_RxOccupancy(dev) != 4) {
  }
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  uint32_t rdata = XLlFifo_RxGetWord(dev);

  return (uint8_t)(rdata & 0xFF);
}

void adau1761::write(uint16_t addr, uint8_t value) {
  XLlFifo* dev = &mDevConfig.fifo_spi;

  XLlFifo_TxPutWord(dev, (mDevConfig.chipAddr << 1) & 0xFF);
  XLlFifo_TxPutWord(dev, (addr >> 8) & 0xFF);
  XLlFifo_TxPutWord(dev, addr & 0xFF);
  XLlFifo_TxPutWord(dev, value);
  XLlFifo_iTxSetLen(dev, 4 * mDevConfig.wordSize);
  while (XLlFifo_RxOccupancy(dev) != 4) {
  }
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
  XLlFifo_RxGetWord(dev);
}

bool adau1761::init_fifos() {
  // Initialize FIFO 0
  XLlFifo_Config* pFIFO_0_Config =
      XLlFfio_LookupConfig(XPAR_AXI_FIFO_MM_S_0_DEVICE_ID);
  uint32_t status = XLlFifo_CfgInitialize(
      &mDevConfig.fifo_spi, pFIFO_0_Config, pFIFO_0_Config->BaseAddress);
  if (status != XST_SUCCESS) {
    cerr << "Could not initialize FIFO 0" << endl;
    return false;
  }

  // Check FIFO 0 status and clear interrupts
  status = XLlFifo_Status(&mDevConfig.fifo_spi);
  if (status != XST_SUCCESS) {
    printf("Status of FIFO 0 not okay. (status = %x)", status);
    return false;
  }
  printf("Clearing interrupts of FIFO 0");
  XLlFifo_IntClear(&mDevConfig.fifo_spi, 0xffffffff);

  status = XLlFifo_Status(&mDevConfig.fifo_spi);
  if (status != XST_SUCCESS) {
    printf("Status of FIFO 0 not okay. (status = %x)", status);
    return false;
  }

  // Initialize FIFO 1
  XLlFifo_Config* pFIFO_1_Config =
      XLlFfio_LookupConfig(XPAR_AXI_FIFO_MM_S_1_BASEADDR);
  uint32_t status = XLlFifo_CfgInitialize(
      &mDevConfig.fifo_i2s, pFIFO_1_Config, pFIFO_1_Config->BaseAddress);
  if (status != XST_SUCCESS) {
    cerr << "Could not initialize FIFO 1" << endl;
    return false;
  }

  // Check FIFO 1 status and clear interrupts
  status = XLlFifo_Status(&mDevConfig.fifo_i2s);
  if (status != XST_SUCCESS) {
    printf("Status of FIFO 1 not okay. (status = %x)", status);
    return false;
  }
  printf("Clearing interrupts of FIFO 1");
  XLlFifo_IntClear(&mDevConfig.fifo_i2s, 0xffffffff);

  status = XLlFifo_Status(&mDevConfig.fifo_i2s);
  if (status != XST_SUCCESS) {
    printf("Status of FIFO 1 not okay. (status = %x)", status);
    return false;
  }

  return true;
}

bool adau1761::initialize() {
  mDevConfig.chipAddr   = 0;
  mDevConfig.wordSize   = 4;
  mDevConfig.buffer     = nullptr; /* TODO: fill with data */
  mDevConfig.buffersize = 0;       /* TODO: set this */

  bool init_fifo_status = init_fifos();
  if (!init_fifo_status)
    return false;

  // Enable F
}
