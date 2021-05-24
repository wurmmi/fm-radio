/**
 * @file    FIFO.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FIFO_H_
#define _FIFO_H_

#include <xllfifo.h>
#include <xscugic.h>

#include <array>
#include <functional>

#define FIFO_NUM_SAMPLES 128
#define FIFO_WORDSIZE    4

typedef struct {
  uint16_t left;
  uint16_t right;
} audio_sample_t;

using audio_buffer_t = std::array<audio_sample_t, FIFO_NUM_SAMPLES>;

class FIFO {
 private:
  XScuGic mIrqCtrl;
  uint8_t mDeviceId;
  std::function<void()> mCallbackOnTxEmptyIRQ;
  bool clear_irqs();
  void irq_handler();
  static void irq_handler_callback(void* data);

 protected:
  XLlFifo mDev;

 public:
  FIFO(uint32_t device_id);
  ~FIFO();

  bool Initialize();
  bool SetupInterrupts(uint32_t irq_id,
                       std::function<void()> const& isEmptyCallback);
};

#endif /* _FIFO_H_ */
