/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Main entry point
 */

#include <FreeRTOS.h>
#include <task.h>

#include <iostream>

#include "AudioHandler.h"
#include "AxiStreamRouter.h"
#include "FMRadioIP_HLS.h"
#include "FMRadioIP_VHDL.h"
#include "MenuControl.h"
#include "log.h"

using namespace std;

#define STACK_SIZE_TASK_AUDIO     ((unsigned short)65535)
#define STACK_SIZE_TASK_HEARTBEAT configMINIMAL_STACK_SIZE

static TaskHandle_t task_heartbeat_handle;
static TaskHandle_t task_audio_handle;

static FMRadioIP_HLS fmRadioIP_HLS(XPAR_FM_RECEIVER_HLS_0_DEVICE_ID);
static FMRadioIP_VHDL fmRadioIP_VHDL;

static void task_heartbeat(void *) {
  while (true) {
    fmRadioIP_HLS.LED_Toggle(TLed::LED1);
    fmRadioIP_VHDL.LED_Toggle(TLed::ALL);
    vTaskDelay(pdMS_TO_TICKS(1000));
  }
}

static void task_audio(void *) {
  AudioHandler audioHandler;
  AxiStreamRouter axiStreamRouter;

  MenuControl::PrintMainMenu();
  while (true) {
    /* Process user input */
    char choice = inbyte();
    printf("%c\n", choice);

    switch (choice) {
      /*-- GENERAL --*/
      case 'h':
        axiStreamRouter.SelectIP(IPSelection::HLS);
        audioHandler.SetIP(&fmRadioIP_HLS);
        break;
      case 'v':
        axiStreamRouter.SelectIP(IPSelection::VHDL);
        audioHandler.SetIP(&fmRadioIP_VHDL);
        break;

      case 'm':
        MenuControl::PrintMainMenu();
        break;
      case 'c':
        audioHandler.ShowAvailableFiles();
        break;
      case 'i': {
        printf("==========================================\n");
        printf("This program is developed by Michael Wurm.\n");
        printf("SDK firmware build date :  %s, %s\n", __DATE__, __TIME__);
        printf("FM Radio IPs:\n");
        fmRadioIP_VHDL.PrintInfo();
        fmRadioIP_HLS.PrintInfo();
        printf("==========================================\n");
      } break;

      /*-- MODE: PASS-THROUGH --*/
      case 'p':
        fmRadioIP_HLS.SetMode(TMode::PASSTHROUGH);
        fmRadioIP_VHDL.SetMode(TMode::PASSTHROUGH);
        audioHandler.PlayFile("cantina_band_44100.wav");
        break;
      case 's':
        audioHandler.Stop();
        LOG_INFO("DMA stopped.");
        break;
      case 'u':
        audioHandler.VolumeUp();
        break;
      case 'd':
        audioHandler.VolumeDown();
        break;

      /*-- MODE: FM RADIO --*/
      case 'x':
        fmRadioIP_HLS.SetMode(TMode::FMRADIO);
        fmRadioIP_VHDL.SetMode(TMode::FMRADIO);
        audioHandler.PlayFile("over_rx_fm_bb.wav");
        break;
      case 'r':
        fmRadioIP_HLS.SetMode(TMode::FMRADIO);
        fmRadioIP_VHDL.SetMode(TMode::FMRADIO);
        audioHandler.PlayFile("limit_rx_fm_bb.wav");
        break;

      default:
        LOG_WARN("Unknown input.\n");
        break;
    }
  }
}

static void Xil_AssertCallbackRoutine(uint8_t *file, int32_t line) {
  printf("Assertion in file %s, on line %0ld\n", file, line);
}

int main() {
  /*--- System setup ---*/
  Xil_DCacheEnable();

  /*--- Program start ---*/
  LOG_INFO("Hello World!");

  xTaskCreate(task_heartbeat,
              (const char *)"task_heartbeat",
              STACK_SIZE_TASK_HEARTBEAT,
              NULL,
              tskIDLE_PRIORITY,
              &task_heartbeat_handle);

  xTaskCreate(task_audio,
              (const char *)"task_audio",
              STACK_SIZE_TASK_AUDIO,
              NULL,
              tskIDLE_PRIORITY,
              &task_audio_handle);

  /* Enable exceptions. */
  Xil_AssertSetCallback((Xil_AssertCallback)Xil_AssertCallbackRoutine);
  Xil_ExceptionEnable();

  vTaskStartScheduler();
  LOG_ERROR("vTaskStartScheduler() returned unexpectedly!");
  while (true) {
  };

  Xil_DCacheDisable();
  return 0;
}
