/*
 * Empty C++ Application
 */

#include <FreeRTOS.h>
#include <task.h>
#include <xil_printf.h>

#include <iostream>

using namespace std;

const TickType_t delay_ms_c = pdMS_TO_TICKS(1000);

int main() {
  cout << "cout Hello World!" << endl;
  printf("printf Hello World!");
  xil_printf("xil_printf Hello World!");

  uint32_t count = 0;
  while (true) {
    cout << "[" << count++ << "] looping ..." << endl;
    vTaskDelay(delay_ms_c);
  }

  return 0;
}
