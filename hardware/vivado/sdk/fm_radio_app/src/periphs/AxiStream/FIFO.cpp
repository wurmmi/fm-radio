/**
 * @file    FIFO.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FIFO.h"

#include <cassert>
#include <iostream>

#include "log.h"

using namespace std;

FIFO::FIFO(uint32_t device_id) : mDeviceId(device_id) {}

FIFO::~FIFO() {}

bool FIFO::Initialize() {
  XLlFifo_Config* pFifoConfig = XLlFfio_LookupConfig(mDeviceId);
  if (pFifoConfig == nullptr) {
    LOG_ERROR("failed LookupConfig()");
    return false;
  }
  int status =
      XLlFifo_CfgInitialize(&mDev, pFifoConfig, pFifoConfig->BaseAddress);
  if (status != XST_SUCCESS) {
    LOG_ERROR("Could not initialize FIFO");
    return false;
  }

  if (!clear_irqs())
    return false;

  return true;
}

bool FIFO::clear_irqs() {
  // Clear interrupts and check interrupt status afterwards
  int status = XLlFifo_Status(&mDev);
  XLlFifo_IntClear(&mDev, 0xffffffff);

  status = XLlFifo_Status(&mDev);
  if (status != XST_SUCCESS) {
    printf("Could not clear interrupts (returned %x)\n", status);
    return false;
  }
  return true;
}

void FIFO::irq_handler() {
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
    } else if (pending & XLLF_INT_RFPF_MASK) {
      // Rx FIFO Programmable Full
      if (mCallbackOnRxFullIRQ != nullptr)
        mCallbackOnRxFullIRQ();
      XLlFifo_IntClear(&mDev, XLLF_INT_RFPF_MASK);
    } else if (pending & XLLF_INT_ERROR_MASK) {
      // Error status
      XLlFifo_IntClear(&mDev, XLLF_INT_ERROR_MASK);
    } else {
      // Unhandled - clear all
      XLlFifo_IntClear(&mDev, pending);
    }
    pending = XLlFifo_IntPending(&mDev);
  }
}

void FIFO::irq_handler_callback(void* context) {
  static_cast<FIFO*>(context)->irq_handler();
}

bool FIFO::SetupInterrupts(uint32_t irq_id,
                           std::function<void()> const& callbackOnTxEmptyIRQ,
                           std::function<void()> const& callbackOnRxFullIRQ) {
  assert(callbackOnTxEmptyIRQ);
  assert(callbackOnRxFullIRQ);
  mCallbackOnTxEmptyIRQ = callbackOnTxEmptyIRQ;
  mCallbackOnRxFullIRQ  = callbackOnRxFullIRQ;

  // Initialize the interrupt controller driver so that it is ready to use.
  XScuGic_Config* IntcConfig =
      XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
  if (IntcConfig == nullptr) {
    printf("XScuGic_LookupConfig() failed\n");
    return false;
  }

  int status =
      XScuGic_CfgInitialize(&mIrqCtrl, IntcConfig, IntcConfig->CpuBaseAddress);
  if (status != XST_SUCCESS) {
    printf("XScuGic_CfgInitialize() failed\n");
    return false;
  }

  XScuGic_SetPriorityTriggerType(&mIrqCtrl, irq_id, 0xA0, 0x03);

  // Connect the device driver handler that will be called when an
  // interrupt for the device occurs, the handler defined above performs
  // the specific interrupt processing for the device.
  status = XScuGic_Connect(
      &mIrqCtrl, irq_id, (Xil_InterruptHandler)irq_handler_callback, this);
  if (status != XST_SUCCESS) {
    printf("XScuGic_Connect() failed\n");
    return false;
  }

  XScuGic_Enable(&mIrqCtrl, irq_id);

  // Initialize the exception table.
  Xil_ExceptionInit();

  // Register the interrupt controller handler with the exception table.
  Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
                               (Xil_ExceptionHandler)XScuGic_InterruptHandler,
                               (void*)&mIrqCtrl);

  // Enable exceptions.
  Xil_ExceptionEnable();

  // Enable FIFO interrupts
  XLlFifo_IntEnable(&mDev, XLLF_INT_ALL_MASK);

  // Start first transmission
  if (mCallbackOnTxEmptyIRQ != nullptr)
    mCallbackOnTxEmptyIRQ();

  return true;
}
