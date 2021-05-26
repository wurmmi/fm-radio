/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Main entry point
 */

#include <FreeRTOS.h>
#include <task.h>

#include <iostream>

#include "AudioHandler.h"
#include "AudioStreamDMA.h"
#include "SDCardReader.h"

using namespace std;

#define STACK_SIZE 4096
const TickType_t delay_ms_c = pdMS_TO_TICKS(1000);

static TaskHandle_t task_loop_handle;
static TaskHandle_t task_audio_handle;

static void task_loop(void *) {
  uint32_t count = 0;
  while (true) {
    cout << "Looping since " << count++ << " sec ..." << endl;
    vTaskDelay(delay_ms_c);
  }
}

static void task_audio(void *) {
  AudioHandler audioHandler;
  SDCardReader sdCardReader;

  const uint8_t num_retries = 5;
  sdCardReader.MountSDCard(num_retries);
  sdCardReader.DiscoverFiles();
  sdCardReader.PrintAvailableFilenames();

  sdCardReader.LoadFile("cantina_band.wav");

  AudioStreamDMA streamDMA(XPAR_AXI_DMA_0_DEVICE_ID);
  if (!streamDMA.Initialize()) {
    cerr << "Error in DMA initialization" << endl;
  }

  DMABuffer buffer = sdCardReader.GetBuffer();
  streamDMA.TransmitBlob(buffer);

  while (true) {
    cout << "task_audio" << endl;
    vTaskDelay(delay_ms_c);
  }
}

int main() {
  cout << "Hello World!" << endl;

  xTaskCreate(task_loop,
              (const char *)"task_loop",
              configMINIMAL_STACK_SIZE,
              NULL,
              tskIDLE_PRIORITY,
              &task_loop_handle);

  xTaskCreate(task_audio,
              (const char *)"task_audio",
              STACK_SIZE,
              NULL,
              tskIDLE_PRIORITY,
              &task_audio_handle);

  vTaskStartScheduler();
  cout << "ERROR: vTaskStartScheduler() returned!" << endl;
  while (true) {
  };
  return 0;
}
