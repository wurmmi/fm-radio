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
  printf("   [h] ... use HLS IP\n");
  printf("   [v] ... use VHDL IP\n");
  printf("\n");
  printf("   [m] ... show this menu\n");
  printf("   [f] ... reset IPOutputFIFO\n");
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

void MenuControl::PrintAppHeader() {
  // clang-format off
  // NOTE: generated with http://patorjk.com/software/taag/
  cout << R"(=============================================================)" << endl;
  cout << R"(                                                             )" << endl;
  cout << R"(_________  ___ ______          _ _          ___              )" << endl;
  cout << R"(|  ___|  \/  | | ___ \        | (_)        / _ \             )" << endl;
  cout << R"(| |_  | .  . | | |_/ /__ _  __| |_  ___   / /_\ \_ __  _ __  )" << endl;
  cout << R"(|  _| | |\/| | |    // _` |/ _` | |/ _ \  |  _  | '_ \| '_ \ )" << endl;
  cout << R"(| |   | |  | | | |\ \ (_| | (_| | | (_) | | | | | |_) | |_) |)" << endl;
  cout << R"(\_|   \_|  |_/ \_| \_\__,_|\__,_|_|\___/  \_| |_/ .__/| .__/ )" << endl;
  cout << R"(                                                | |   | |    )" << endl;
  cout << R"( ... by Michael Wurm                            |_|   |_|    )" << endl;
  cout << R"(=============================================================)" << endl;
  cout << endl;
  // clang-format on
}
