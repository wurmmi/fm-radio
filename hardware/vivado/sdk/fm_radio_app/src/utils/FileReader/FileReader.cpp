/**
 * @file    FileReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FileReader.h"

#include <algorithm>
#include <iostream>

#include "WavReader.h"
#include "log.h"

#ifdef __CSIM__
#include <cerrno>
#include <cstring>
#endif

using namespace std;

FileReader::FileReader() {
  mFileIsOpen = false;
}

FileReader::~FileReader() {
  if (mBuffer.buffer) {
    delete[] mBuffer.buffer;
    mBuffer = {nullptr, 0};
  }
  if (mFileIsOpen)
    FileClose();
}

void FileReader::SwapLeftAndRight() {
  if (mBuffer.buffer == nullptr) {
    LOG_ERROR("no file loaded yet");
    return;
  }

  LOG_DEBUG("swap left and right channel");
  uint32_t* pSource = (uint32_t*)mBuffer.buffer;
  for (size_t i = 0; i < mBuffer.size / 4; i++) {
    // Split 32 bit into 2x 16 bit
    int16_t left  = (int16_t)((pSource[i] >> 16) & 0xFFFF);
    int16_t right = (int16_t)((pSource[i] >> 0) & 0xFFFF);

    // Combine to 32 bit again (reversed)
    pSource[i] = ((uint32_t)right << 16) + (uint32_t)left;
  }
}

bool FileReader::LoadFile(std::string const& filename) {
  LOG_ERROR("Not implemented here");
  return false;
}

FileType FileReader::GetFileType(string const& filename) {
  string filename_lower = filename;
  transform(
      filename.cbegin(), filename.cend(), filename_lower.begin(), ::tolower);

  if (filename_lower.find(".txt") != string::npos) {
    return FileType::TXT;
  }
  if (filename_lower.find(".wav") != string::npos) {
    return FileType::WAV;
  }

  return FileType::UNKNOWN;
}

DMABuffer FileReader::GetBuffer() {
  return mBuffer;
}

bool FileReader::FileOpen(std::string const& filename, FileOpenMode openMode) {
#ifdef __CSIM__
  string mode_str;
  switch (openMode) {
    case FileOpenMode::READ:
      mode_str = "read";
      mFile    = fopen(filename.c_str(), "r");
      break;
    case FileOpenMode::WRITE:
      mode_str = "write";
      mFile    = fopen(filename.c_str(), "w");
      break;

    default:
      LOG_ERROR("unhandled FileOpenMode");
      break;
  }
  if (!mFile) {
    LOG_ERROR("Error opening file to %s! (error: %s)",
              mode_str.c_str(),
              strerror(errno));
    return false;
  }
#else
  string mode_str;
  FRESULT fres;
  switch (openMode) {
    case FileOpenMode::READ:
      mode_str = "read";
      fres     = f_open(&mFile, filename.c_str(), FA_READ);
      break;
    case FileOpenMode::WRITE:
      mode_str = "write";
      fres     = f_open(&mFile, filename.c_str(), FA_WRITE | FA_CREATE_ALWAYS);
      break;

    default:
      LOG_ERROR("unhandled FileOpenMode");
      break;
  }
  if (fres) {
    LOG_ERROR("Error opening file to %s! (error: %d)", mode_str.c_str(), fres);
    return false;
  }
#endif

  mFileIsOpen = true;
  return true;
}

void FileReader::FileClose() {
#ifdef __CSIM__
  fclose(mFile);
#else
  f_close(&mFile);
#endif
  mFileIsOpen = false;
}

bool FileReader::FileRead(void* target_buf,
                          size_t num_bytes_to_read,
                          size_t& n_bytes_read) {
  // Read bytes from the file
#ifdef __CSIM__
  n_bytes_read = fread(target_buf, 1, num_bytes_to_read, mFile);
#else
  FRESULT fres = f_read(&mFile, target_buf, num_bytes_to_read, &n_bytes_read);
  if (fres) {
    LOG_ERROR("Failed to read file. (error: %d)", fres);
    FileClose();
    return false;
  }
#endif

  // Check if the requested amount was read
  if (n_bytes_read != num_bytes_to_read) {
    LOG_WARN("Read less than requested (%zu < %zu).",
             n_bytes_read,
             num_bytes_to_read);
    FileClose();
    return false;
  }

  return true;
}

bool FileReader::FileWrite(std::vector<uint32_t> const& data) {
#ifdef __CSIM__
  size_t num_elems_to_write = data.size();
  size_t n_elems_written =
      fwrite((void*)data.data(), sizeof(uint32_t), num_elems_to_write, mFile);

  // Check if the requested amount was written
  if (n_elems_written != num_elems_to_write) {
    LOG_WARN("Wrote less than requested (%zu < %zu).",
             n_elems_written,
             n_elems_written);
    FileClose();
    return false;
  }

#else
  size_t num_bytes_to_write = data.size() * sizeof(uint32_t);
  size_t n_bytes_written    = 0;
  FRESULT fres =
      f_write(&mFile, (void*)data.data(), num_bytes_to_write, &n_bytes_written);
  if (fres) {
    LOG_ERROR("Failed to write to file. (error: %d)", fres);
    FileClose();
    return false;
  }

  // Check if the requested amount was written
  if (n_bytes_written != num_bytes_to_write) {
    LOG_WARN("Wrote less than requested (%zu < %zu).",
             n_bytes_written,
             n_bytes_written);
    FileClose();
    return false;
  }
#endif
  return true;
}

bool FileReader::FileSeek(size_t num_bytes_offset) {
  // Advance the file pointer by n byte
#ifdef __CSIM__
  int res = fseek(mFile, num_bytes_offset, SEEK_CUR);
#else
  DWORD fp_current = f_tell(&mFile);
  FRESULT res      = f_lseek(&mFile, fp_current + num_bytes_offset);
#endif

  if (res) {
    LOG_ERROR("Failed to seek. (error: %d)", res);
    FileClose();
    return false;
  }

  return true;
}
