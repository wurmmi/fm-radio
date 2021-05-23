/**
 * @file    FifoHandler.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FifoHandler.h"

#include <xstatus.h>

#include <iostream>

using namespace std;

FifoHandler::FifoHandler(uint32_t device_id) : mDeviceId(device_id) {}

FifoHandler::~FifoHandler() {}

bool FifoHandler::Initialize() {
  XLlFifo_Config* pFifoConfig = XLlFfio_LookupConfig(mDeviceId);
  int status =
      XLlFifo_CfgInitialize(&mDev, pFifoConfig, pFifoConfig->BaseAddress);
  if (status != XST_SUCCESS) {
    cerr << "Could not initialize FIFO" << endl;
    return false;
  }

  // Clear interrupts and check interrupt status afterwards
  status = XLlFifo_Status(&mDev);
  printf("Clearing interrupts of FIFO\n");
  XLlFifo_IntClear(&mDev, 0xffffffff);

  status = XLlFifo_Status(&mDev);
  if (status != XST_SUCCESS) {
    printf("Could not clear interrupts (returned %x)\n", status);
    return false;
  }

  return true;
}

void FifoHandler::SetIrqCallback(std::function<void()> const& callback) {
  mCallbackOnTxEmptyIRQ = callback;
}

void FifoHandler::irq_handler() {
  uint32_t pending = XLlFifo_IntPending((&mDev));
  while (pending) {
    if (pending & XLLF_INT_RC_MASK) {
      // Receive complete
      XLlFifo_IntClear(&mDev, XLLF_INT_RC_MASK);
    } else if (pending & XLLF_INT_TC_MASK) {
      // Transmit complete
      XLlFifo_IntClear(&mDev, XLLF_INT_TC_MASK);
    } else if (pending & XLLF_INT_TFPE_MASK) {
      // Tx FIFO Programmable Empty
      if (mCallbackOnTxEmptyIRQ != nullptr)
        mCallbackOnTxEmptyIRQ();
      XLlFifo_IntClear(&mDev, XLLF_INT_TFPE_MASK);
    } else if (pending & XLLF_INT_ERROR_MASK) {
      // Error status
      XLlFifo_IntClear(&mDev, XLLF_INT_ERROR_MASK);
    } else {
      XLlFifo_IntClear(&mDev, pending);
    }
    pending = XLlFifo_IntPending(&mDev);
  }
}
