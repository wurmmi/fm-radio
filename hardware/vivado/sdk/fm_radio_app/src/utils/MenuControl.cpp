/**
 * @file    MenuControl.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "MenuControl.h"

#include <iostream>

using namespace std;

MenuControl::MenuControl() {}

MenuControl::~MenuControl() {}

void MenuControl::PrintMainMenu() {
  printf("-------------- FM RADIO MENU -----------------\n");
  printf("GENERAL\n");
  printf("   [m] ... show this menu\n");
  printf("   [c] ... print available filenames on SD card\n");
  printf("   [i] ... show information\n");
  printf("MODE: PASS-THROUGH \n");
  printf("   [p] ... play\n");
  printf("   [s] ... stop\n");
  printf("   [u] ... volume up\n");
  printf("   [d] ... volume down\n");
  printf("MODE: FM RADIO \n");
  printf("   [r] ... play\n");
  printf("   [s] ... stop\n");
  printf("----------------------------------------------\n");
  printf("Choice: ");
  fflush(stdout);
}
