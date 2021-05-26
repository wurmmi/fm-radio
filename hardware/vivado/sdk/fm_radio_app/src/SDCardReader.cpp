/**
 * @file    SDCardReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "SDCardReader.h"

#include <iostream>

using namespace std;

SDCardReader::SDCardReader() {
  mMounted = false;
}

SDCardReader::~SDCardReader() {}

bool SDCardReader::MountSDCard(uint8_t num_retries) {
  while (num_retries--) {
    cout << "Mounting SD Card" << endl;
    FRESULT result = f_mount(&mFilesystem, LOGICAL_DRIVE_0, 1);
    if (result != 0) {
      cout << "Couldn't mount SD Card. Press RETURN to try again" << endl;
      getchar();
      continue;
    }
    mMounted = true;
    return true;
  }
  mMounted = false;
  return false;
}

void SDCardReader::DiscoverFiles() {
  if (!mMounted) {
    cerr << "No SDCard mounted!" << endl;
    return;
  }

  DIR dir;
  FRESULT res = f_opendir(&dir, LOGICAL_DRIVE_0);
  if (res != FR_OK) {
    cout << "Couldn't read root directory." << endl;
    return;
  }

  do {
    FILINFO fno;
    res = f_readdir(&dir, &fno);
    if (res != FR_OK || fno.fname[0] == 0) {
      break;
    }

    string filename = string(fno.fname);
    cout << "filename = " << filename << endl;
    mFilenames.emplace_back(filename);

    if (fno.fattrib & AM_DIR) {
      cout << "Directory: " << filename << endl;
    } else if (filename.find(".TXT") != string::npos ||
               filename.find(".txt") != string::npos) {
      cout << " --> is a *.txt file!" << endl;
    }
  } while (res == FR_OK);

  f_closedir(&dir);

  if (mFilenames.size() == 0)
    cout << "No files found." << endl;
}

void SDCardReader::PrintAvailableFilenames() const {
  cout << "--- Available files on SD card: ---" << endl;
  for (uint32_t i = 0; i < mFilenames.size(); i++) {
    printf("[%3d]: %s\n", (int)i, mFilenames[i].c_str());
  }
  cout << "-----------------------------------" << endl;
}
