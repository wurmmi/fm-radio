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

FileReader::FileReader() {}

FileReader::~FileReader() {
  if (mBuffer.buffer) {
    delete[] mBuffer.buffer;
    mBuffer = {nullptr, 0};
  }
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

void FileReader::PrepareBufferData() {
  // Change the volume and swap left/right channel and polarity

  uint32_t* pSource = (uint32_t*)mBuffer.buffer;
  for (size_t i = 0; i < mBuffer.size / 4; i++) {
    // Split 32 bit into 2x 16 bit
    int16_t left  = (int16_t)((pSource[i] >> 16) & 0xFFFF);
    int16_t right = (int16_t)((pSource[i] >> 0) & 0xFFFF);

    // Adapt volume
    /** NOTE: could be an Axilite parameter in the future*/
    const int theVolume = 1;

    left  = left * theVolume / 4;
    right = right * theVolume / 4;

    // Limit amplitude to 16 bit
    //    if (left > 32767)
    //      left = 32767;
    //    if (left < -32767)
    //      left = -32767;
    //    if (right > 32767)
    //      right = 32767;
    //    if (right < -32767)
    //      right = -32767;

    // Combine to 32 bit again
    pSource[i] = ((uint32_t)right << 16) + (uint32_t)left;
  }
}

bool FileReader::FileOpen(std::string const& filename) {
#ifdef __CSIM__
  mFile = fopen(filename.c_str(), "r");
  if (!mFile) {
    LOG_ERROR("Error opening file! (error: %s)", strerror(errno));
    return false;
  }
#else
  FRESULT fres = f_open(&mFile, filename.c_str(), FA_READ);
  if (fres) {
    LOG_ERROR("Error opening file! (error: %d)", fres);
    return false;
  }
#endif

  return true;
}

void FileReader::FileClose() {
#ifdef __CSIM__
  fclose(mFile);
#else
  f_close(&mFile);
#endif
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
    LOG_ERROR("Failed to read file.");
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
