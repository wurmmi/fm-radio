/**
 * @file    FifoHandler.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FIFOHANDLER_H_
#define _FIFOHANDLER_H_

#include <xllfifo.h>

#include <functional>

/** TODO: This is a base class.
/*       --> Derive ConfigFifo and AudioStreamFifo from it.
/*       --> because of different read/write functions.
*/
class FifoHandler {
 private:
  XLlFifo mDev;
  uint8_t mDeviceId;
  std::function<void()> mCallbackOnTxEmptyIRQ;

  void irq_handler();

 public:
  FifoHandler(uint32_t device_id);
  ~FifoHandler();

  bool Initialize();
  void SetIrqCallback(std::function<void()> const& callback);
};

#endif /* _FIFOHANDLER_H_ */
