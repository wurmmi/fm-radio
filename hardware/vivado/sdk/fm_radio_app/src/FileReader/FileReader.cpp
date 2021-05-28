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

using namespace std;

FileReader::FileReader() {}

FileReader::~FileReader() {
  if (mBuffer) {
    free(mBuffer);
    mBuffer = nullptr;
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

void FileReader::PrepareBufferData() {
  // Change the volume and swap left/right channel and polarity

  int theVolume = 2;

  uint32_t* pSource = (uint32_t*)mBuffer;
  for (uint32_t i = 0; i < mBufferSize / 4; i++) {
    short left  = (short)((pSource[i] >> 16) & 0xFFFF);
    short right = (short)((pSource[i] >> 0) & 0xFFFF);
    int left_i  = -(int)left * theVolume / 4;
    int right_i = -(int)right * theVolume / 4;
    if (left > 32767)
      left = 32767;
    if (left < -32767)
      left = -32767;
    if (right > 32767)
      right = 32767;
    if (right < -32767)
      right = -32767;
    left       = (short)left_i;
    right      = (short)right_i;
    pSource[i] = ((uint32_t)right << 16) + (uint32_t)left;
  }
}

DMABuffer FileReader::GetBuffer() {
  return {mBuffer, mBufferSize};
}