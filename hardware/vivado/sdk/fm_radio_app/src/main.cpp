/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Main entry point
 */

#include <FreeRTOS.h>
#include <task.h>

#include <iostream>

#include "AudioHandler.h"
#include "FMRadioIP.h"
#include "log.h"

using namespace std;

#define STACK_SIZE_TASK_AUDIO ((uint16_t)65535)

static TaskHandle_t task_heartbeat_handle;
static TaskHandle_t task_audio_handle;
static FMRadioIP fmRadioIP(XPAR_FM_RECEIVER_HLS_0_DEVICE_ID);

static void task_heartbeat(void *) {
  while (true) {
    fmRadioIP.LED_Toggle(TLed::LED1);
    vTaskDelay(pdMS_TO_TICKS(1000));
  }
}

static void task_audio(void *) {
  AudioHandler audioHandler;

  while (true) {
    /* Show menu */
    printf("-------------- FM RADIO MENU -----------------\n");
    printf("[p] ... play audio  (pass-through)\n");
    printf("[u] ... volume up   (pass-through)\n");
    printf("[d] ... volume down (pass-through)\n");
    printf("\n");
    printf("[r] ... play radio  (FM Radio)\n");
    printf("[s] ... stop\n");
    printf("\n");
    printf("[c] ... print available filenames on SD card\n");
    printf("[i] ... show information\n");
    printf("----------------------------------------------\n");
    printf("Choice: ");
    fflush(stdout);

    /* Process user input */
    char choice = inbyte();
    printf("%c\n", choice);

    switch (choice) {
      case 'p': {
        audioHandler.PlayFile("cantina_band_44100.wav");
      } break;
      case 'u':
        audioHandler.VolumeUp();
        break;
      case 'd':
        audioHandler.VolumeDown();
        break;

      case 'r': {
        audioHandler.PlayFile("rx_fm_bb.wav");
      } break;
      case 's':
        audioHandler.Stop();
        LOG_INFO("DMA stopped.");
        break;

      case 'c':
        audioHandler.ShowAvailableFiles();
        break;
      case 'i': {
        string build_time = fmRadioIP.GetBuildTime();
        string git_hash   = fmRadioIP.GetGitHash();

        printf("This program is developed by Michael Wurm.\n");
        printf("SDK firmware build date :  %s, %s\n", __DATE__, __TIME__);
        printf("FM Radio IP build date  :  %s, (git hash: %s)\n",
               build_time.c_str(),
               git_hash.c_str());
      } break;

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

  xTaskCreate(task_heartbeat,
              (const char *)"task_heartbeat",
              configMINIMAL_STACK_SIZE,
              NULL,
              tskIDLE_PRIORITY,
              &task_heartbeat_handle);

  xTaskCreate(task_audio,
              (const char *)"task_audio",
              STACK_SIZE_TASK_AUDIO,
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
