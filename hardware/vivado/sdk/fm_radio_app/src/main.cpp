/*
 * Empty C++ Application
 */

#include <FreeRTOS.h>
#include <task.h>

#include <iostream>

#include "adau1761.h"

using namespace std;

const TickType_t delay_ms_c = pdMS_TO_TICKS(1000);

static TaskHandle_t task_1;

static void task_loop(void *) {
  static uint32_t count = 0;
  while (true) {
    cout << "[" << count++ << "] looping ..." << endl;
    vTaskDelay(delay_ms_c);
  }
}

int main() {
  cout << "cout Hello World!" << endl;

  xTaskCreate(task_loop, /* The function that implements the task. */
              (const char *)"task_loop", /* Text name for the task, provided to
                                     assist debugging only. */
              configMINIMAL_STACK_SIZE,  /* The stack allocated to the task. */
              NULL, /* The task parameter is not used, so set to NULL. */
              tskIDLE_PRIORITY, /* The task runs at the idle priority. */
              &task_1);

  vTaskStartScheduler();
  cout << "ERROR: vTaskStartScheduler() returned!" << endl;
  while (true) {
  };
  return 0;
}
