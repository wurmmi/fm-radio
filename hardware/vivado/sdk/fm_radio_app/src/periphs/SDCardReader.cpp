/**
 * @file    SDCardReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "SDCardReader.h"

#include <algorithm>
#include <fstream>
#include <iostream>

#include "TxtReader.h"
#include "WavReader.h"
#include "log.h"

using namespace std;

SDCardReader::SDCardReader() {
  mMounted                  = false;
  mCurrentlyLoadedFilename  = "";
  const uint8_t num_retries = 5;
  MountSDCard(num_retries);
  DiscoverFiles();
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
  mFilenames.clear();
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
  mFilenames.clear();
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
  /* Transform to upper case letters */
  string fn_upper = filename;
  transform(filename.cbegin(), filename.cend(), fn_upper.begin(), ::toupper);

  /* Split name and extension */
  auto dot_idx     = fn_upper.find_last_of('.');
  string extension = fn_upper.substr(dot_idx);
  string name      = fn_upper.substr(0, dot_idx);

  // Truncate name
  const uint8_t short_filename_length_c = 8;

  string short_name;
  if (name.length() > short_filename_length_c) {
    // too long: truncate and add "~1"
    name       = name.substr(0, short_filename_length_c - 2);
    short_name = name + "~1" + extension;
  } else {
    short_name = name + extension;
  }
  LOG_DEBUG("filename       : %s", filename.c_str());
  LOG_DEBUG("filename_upper : %s", fn_upper.c_str());
  LOG_DEBUG("extension      : %s", extension.c_str());
  LOG_DEBUG("short_name     : %s", short_name.c_str());
  return short_name;
}

bool SDCardReader::LoadFile(string const& filename) {
  if (!IsMounted() || !FoundFiles()) {
    return false;
  }

  // Check if this filename was previously discovered
  string filename_short = GetShortFilename(filename);
  auto iter = find(mFilenames.cbegin(), mFilenames.cend(), filename_short);
  if (iter == mFilenames.cend()) {
    LOG_ERROR("File '%s' does not exist.", filename_short.c_str());
    return false;
  }

  // Handle file depending on its type
  FileType fileType = FileReader::GetFileType(filename);

  bool success = false;
  switch (fileType) {
    case FileType::WAV: {
      mFileReader = new WavReader();
      success     = mFileReader->LoadFile(filename_short);
    } break;
    case FileType::TXT:
      LOG_INFO("Reading TXT file '%s' ...", filename.c_str());
      mFileReader = new TxtReader();
      success     = mFileReader->LoadFile(filename_short);
      break;

    case FileType::UNKNOWN:
    default:
      LOG_ERROR("Unknown filetype of file: %s (short: %s)",
                filename.c_str(),
                filename_short.c_str());
      success = false;
      break;
  }

  if (!success)
    LOG_ERROR("Could not load file!");
  mCurrentlyLoadedFilename = filename;

  return success;
}

bool SDCardReader::WriteFile(std::string const& filename,
                             std::vector<uint32_t> data,
                             bool overwrite) {
  if (!IsMounted()) {
    return false;
  }
  LOG_INFO("Writing TXT file '%s' ...", filename.c_str());

  ofstream fp;
  if (overwrite)
    fp.open(filename, ios::out);
  else
    fp.open(filename, ios::out | ios::app);
  if (!fp.is_open()) {
    LOG_ERROR("could not create/open file '%s'!", filename.c_str());
    return false;
  }

  for (auto const& elem : data) {
    fp << elem << endl;
  }
  fp.close();

  return true;
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

std::string const& SDCardReader::GetCurrentlyLoadedFilename() {
  return mCurrentlyLoadedFilename;
}
