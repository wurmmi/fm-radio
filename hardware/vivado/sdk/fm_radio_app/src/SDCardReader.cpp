/**
 * @file    SDCardReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "SDCardReader.h"

#include <algorithm>
#include <iostream>

#include "TxtReader.h"
#include "WavReader.h"
#include "log.h"

using namespace std;

SDCardReader::SDCardReader() {
  mMounted = false;
}

SDCardReader::~SDCardReader() {}

bool SDCardReader::IsMounted() {
  if (!mMounted) {
    LOG_ERROR("No SDCard mounted!");
  }
  return mMounted;
}

bool SDCardReader::FoundFiles() {
  if (mFilenames.size() == 0) {
    LOG_ERROR("No files found on SD card!");
    return false;
  }
  return true;
}

bool SDCardReader::MountSDCard(uint8_t num_retries) {
  while (num_retries--) {
    LOG_DEBUG("Mounting SD Card");
    FRESULT result = f_mount(&mFilesystem, LOGICAL_DRIVE_0, 1);
    if (result != 0) {
      LOG_WARN("Couldn't mount SD Card. Press RETURN to try again");
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
  if (!IsMounted()) {
    return;
  }

  DIR dir;
  FRESULT res = f_opendir(&dir, LOGICAL_DRIVE_0);
  if (res != FR_OK) {
    LOG_ERROR("Couldn't read root directory.");
    return;
  }

  LOG_DEBUG("Discovering files: ");
  do {
    FILINFO fno;
    res = f_readdir(&dir, &fno);
    if (res != FR_OK || fno.fname[0] == 0) {
      break;
    }

    string filename = string(fno.fname);

    if (fno.fattrib & AM_DIR) {
      LOG_DEBUG("- found directory: %s", filename.c_str());
    } else {
      LOG_DEBUG("- found file: %s", filename.c_str());
      mFilenames.emplace_back(filename);
    }
  } while (res == FR_OK);

  f_closedir(&dir);

  if (mFilenames.size() == 0)
    LOG_WARN("No files found.");
}

string SDCardReader::GetShortFilename(string const& filename) {
  string fn_upper = filename;
  transform(filename.cbegin(), filename.cend(), fn_upper.begin(), ::toupper);

  auto dot_idx     = fn_upper.find_last_of('.');
  string extension = fn_upper.substr(dot_idx);
  string name      = fn_upper.substr(0, dot_idx);

  const uint8_t short_filename_length_c = 6;
  if (name.length() >= short_filename_length_c)
    name = name.substr(0, short_filename_length_c);

  string short_name = name + "~1" + extension;
  LOG_DEBUG("filename  : %s", filename.c_str());
  LOG_DEBUG("extension : %s", extension.c_str());
  LOG_DEBUG("short_name: %s", short_name.c_str());
  return short_name;
}

void SDCardReader::LoadFile(string const& filename) {
  if (!IsMounted() || !FoundFiles()) {
    return;
  }

  // Check if this filename was previously discovered
  string filename_short = GetShortFilename(filename);
  auto iter = find(mFilenames.cbegin(), mFilenames.cend(), filename_short);
  if (iter == mFilenames.cend()) {
    LOG_ERROR("File '%s' does not exist.", filename_short.c_str());
    return;
  }

  // Handle file depending on its type
  FileType fileType = FileReader::GetFileType(filename);

  switch (fileType) {
    case FileType::WAV: {
      mFileReader = new WavReader();
      mFileReader->LoadFile(filename_short);
    } break;
    case FileType::TXT:
      mFileReader = new TxtReader();
      mFileReader->LoadFile(filename_short);
      break;

    case FileType::UNKNOWN:
    default:
      LOG_ERROR("Unknown filetype of file: %s (short: %s)",
                filename.c_str(),
                filename_short.c_str());
      break;
  }
}

void SDCardReader::PrintAvailableFilenames() const {
  cout << "--- Available files on SD card: ---" << endl;
  for (uint32_t i = 0; i < mFilenames.size(); i++) {
    printf("[%3d]: %s\n", (int)i, mFilenames[i].c_str());
  }
  cout << "-----------------------------------" << endl;
}

DMABuffer SDCardReader::GetBuffer() {
  return mFileReader->GetBuffer();
}
