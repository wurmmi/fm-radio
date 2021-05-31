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
#include "FMRadioIP.h"
#include "SDCardReader.h"
#include "log.h"

using namespace std;

#define STACK_SIZE ((uint16_t)65535)

const TickType_t delay_ms_c = pdMS_TO_TICKS(1000);

static TaskHandle_t task_loop_handle;
static TaskHandle_t task_audio_handle;

static void task_loop(void *) {
  FMRadioIP fmRadioIP(XPAR_FM_RECEIVER_HLS_0_DEVICE_ID);

  while (true) {
    fmRadioIP.LED_Toggle(TLed::LED1);
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

  AudioStreamDMA streamDMA(XPAR_AXI_DMA_0_DEVICE_ID);

  while (true) {
    /* Show menu */
    printf("-------------- FM RADIO MENU -----------------\n");
    printf("[p] ... play audio (cantina band)\n");
    printf("[r] ... play audio (fm radio)\n");
    printf("[s] ... stop\n");
    printf("[i] ... show information\n");
    printf("----------------------------------------------\n");
    printf("Choice: ");

    /* Process user input */
    fflush(stdout);
    char choice = inbyte();
    printf("%c\n", choice);

    DMABuffer buffer = {nullptr, 0};
    switch (choice) {
      case 'p': {
        sdCardReader.LoadFile("cantina_band_44100.wav");
        buffer = sdCardReader.GetBuffer();
        streamDMA.TransmitBlob(buffer);
        LOG_INFO("DMA playing in endless loop ...");
      } break;
      case 'r': {
        sdCardReader.LoadFile("rx_fm_bb.wav");
        buffer = sdCardReader.GetBuffer();
        streamDMA.TransmitBlob(buffer);
        LOG_INFO("DMA playing in endless loop ...");
      } break;
      case 's':
        streamDMA.Stop();
        LOG_INFO("DMA stopped.");
        break;
      case 'i':
        printf("This program is developed by Michael Wurm.\n");
        printf("SDK  build date:  %s, %s\n", __DATE__, __TIME__);
        printf("FPGA build date:  %s, (%s)\n", "date", "git hash");
        break;

      default:
        LOG_WARN("Unknown input.\n");
        break;
    }
  }
}

int main() {
  /*--- System setup ---*/
  Xil_DCacheEnable();

  /*--- Program start ---*/
  LOG_INFO("Hello World!");

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
  LOG_ERROR("vTaskStartScheduler() returned unexpectedly!");
  while (true) {
  };

  Xil_DCacheDisable();
  return 0;
}
