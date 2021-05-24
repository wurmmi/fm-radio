/**
 * @file    SDCardReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "SDCardReader.h"

#include <iostream>

using namespace std;

SDCardReader::SDCardReader() {}

SDCardReader::~SDCardReader() {}

bool SDCardReader::MountSDCard(uint8_t num_retries) {
  while (num_retries--) {
    cout << "Mounting SD Card" << endl;
    FRESULT result = f_mount(&mFilesystem, "0:/", 1);
    if (result != 0) {
      cout << "Couldn't mount SD Card. Press RETURN to try again" << endl;
      getchar();
      continue;
    }
    return true;
  }
  return false;
}

void SDCardReader::DiscoverFiles() {
  DIR dir;
  FRESULT res = f_opendir(&dir, "0:/");
  if (res != FR_OK) {
    cout << "Couldn't read root directory." << endl;
    return;
  }

  do {
    FILINFO fno;
    res = f_readdir(&dir, &fno);
    cout << "res = " << res << endl;
    cout << "fno.fname = " << fno.fname << endl;

    if (res != FR_OK || fno.fname[0] == 0) {
      break;
    }

    if (fno.fattrib & AM_DIR) {
    } else if (string(fno.fname).find(".wav")) {
    } else {
      mFilenames.emplace_back(fno.fname);
    }
  } while (res == FR_OK);

  f_closedir(&dir);

  if (mFilenames.size() == 0)
    cout << "No files found." << endl;
}

void SDCardReader::PrintAvailableFilenames() const {
  cout << "--- Available files on SD card: ---" << endl;
  for (uint32_t i = 0; i < mFilenames.size(); i++) {
    printf("[%3d]: %s", (int)i, mFilenames[i].c_str());
  }
  cout << "-----------------------------------" << endl;
}
