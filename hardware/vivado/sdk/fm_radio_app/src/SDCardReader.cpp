/**
 * @file    SDCardReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "SDCardReader.h"

#include <algorithm>
#include <iostream>

using namespace std;

SDCardReader::SDCardReader() {
  mMounted = false;
}

SDCardReader::~SDCardReader() {}

bool SDCardReader::IsMountedAndFoundFiles() {
  bool ret = true;
  if (!mMounted) {
    cerr << "No SDCard mounted!" << endl;
    ret = false;
  }
  if (mFilenames.size() == 0) {
    cerr << "No files found on SD card!" << endl;
    ret = false;
  }
  return ret;
}

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
  if (!IsMountedAndFoundFiles()) {
    return;
  }

  DIR dir;
  FRESULT res = f_opendir(&dir, LOGICAL_DRIVE_0);
  if (res != FR_OK) {
    cout << "Couldn't read root directory." << endl;
    return;
  }

  cout << "Discovering files: " << endl;
  do {
    FILINFO fno;
    res = f_readdir(&dir, &fno);
    if (res != FR_OK || fno.fname[0] == 0) {
      break;
    }

    string filename = string(fno.fname);

    if (fno.fattrib & AM_DIR) {
      cout << "- found directory: " << filename << endl;
    } else {
      cout << "- found file: " << filename << endl;
      mFilenames.emplace_back(filename);
    }
  } while (res == FR_OK);

  f_closedir(&dir);

  if (mFilenames.size() == 0)
    cout << "No files found." << endl;
}

void SDCardReader::LoadFile(string& filename) {
  if (!IsMountedAndFoundFiles()) {
    return;
  }

  // Check if this filename was previously discovered
  auto iter = find(mFilenames.cbegin(), mFilenames.cend(), filename);
  if (iter == mFilenames.cend()) {
    cerr << "File '" << filename << "' does not exist." << endl;
    return;
  }

  mFileReader.LoadFile(filename);
}

void SDCardReader::PrintAvailableFilenames() const {
  cout << "--- Available files on SD card: ---" << endl;
  for (uint32_t i = 0; i < mFilenames.size(); i++) {
    printf("[%3d]: %s\n", (int)i, mFilenames[i].c_str());
  }
  cout << "-----------------------------------" << endl;
}
