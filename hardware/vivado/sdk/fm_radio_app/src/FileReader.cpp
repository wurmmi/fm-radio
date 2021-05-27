/**
 * @file    FileReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FileReader.h"

#include <algorithm>
#include <iostream>

#include "log.h"

using namespace std;

typedef struct {
  char riff[4];
  uint32_t riffSize;
  char wave[4];
} wav_header_t;

typedef struct {
  char ckId[4];
  uint32_t cksize;
} wav_generic_chunk_t;

typedef struct {
  uint16_t wFormatTag;
  uint16_t nChannels;
  uint32_t nSamplesPerSec;
  uint32_t nAvgBytesPerSec;
  uint16_t nBlockAlign;
  uint16_t wBitsPerSample;
  uint16_t cbSize;
  uint16_t wValidBitsPerSample;
  uint32_t dwChannelMask;
  u8 SubFormat[16];
} wav_fmt_chunk_t;

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

void FileReader::LoadFile(string const& filename) {
  // Handle file depending on its type
  FileType fileType = GetFileType(filename);
  if (fileType == FileType::UNKNOWN) {
    cerr << "Unknown filetype of file: " << filename << endl;
    return;
  }

  // Open the file
  FRESULT fres = f_open(&mFile, filename.c_str(), FA_READ);
  if (fres) {
    cerr << "Error opening file! (error: " << fres << ")" << endl;
    return;
  }

  // Read file depending on type
  switch (fileType) {
    case FileType::WAV:
      ReadWAV();
      cout << "Read " << mBufferSize << " bytes from WAV file " << filename
           << endl;
      break;
    case FileType::TXT:
      ReadTXT();
      break;

    case FileType::UNKNOWN:
    default:
      break;
  }

  f_close(&mFile);
}

void FileReader::ReadWAV() {
  cout << "Reading WAV file." << endl;

  /*--- Sanity checks ---*/

  // WAV header
  wav_header_t header;
  UINT n_bytes_read;
  FRESULT fres = f_read(&mFile, (void*)&header, sizeof(header), &n_bytes_read);
  if (fres) {
    LOG_ERROR("Failed to read file.");
    return;
  }

  if (string{header.riff, sizeof(header.riff)} != "RIFF") {
    LOG_ERROR("Illegal WAV file format, RIFF not found.");
    return;
  }

  if (string{header.wave, sizeof(header.riff)} != "WAVE") {
    LOG_ERROR("Illegal WAV file format, WAVE not found.");
    return;
  }

  /*--- Read chunks ---*/
  uint32_t num_generic_chunks = 0;
  uint32_t num_unknown_chunks = 0;
  uint32_t num_fmt_chunks     = 0;
  uint32_t num_data_chunks    = 0;

  while (1) {
    // Read WAV generic chunk
    wav_generic_chunk_t genericChunk;
    fres = f_read(
        &mFile, (void*)&genericChunk, sizeof(genericChunk), &n_bytes_read);
    if (fres) {
      LOG_ERROR("Failed to read file.");
      return;
    } else if (n_bytes_read != sizeof(genericChunk)) {
      // probably reached EOF
      break;
    }

    num_generic_chunks++;

    wav_fmt_chunk_t fmtChunk;
    if (string{genericChunk.ckId, sizeof(genericChunk.ckId)} == "fmt ") {
      num_fmt_chunks++;

      // "fmt" chunk is compulsory and contains information
      // about the sample
      // format
      fres =
          f_read(&mFile, (void*)&fmtChunk, genericChunk.cksize, &n_bytes_read);
      if (fres != 0) {
        LOG_ERROR("Failed to read file");
        return;
      }
      if (n_bytes_read != genericChunk.cksize) {
        LOG_ERROR("EOF reached");
        return;
      }
      if (fmtChunk.wFormatTag != 1) {
        LOG_ERROR("Unsupported format");
        return;
      }
      if (fmtChunk.nChannels != 2) {
        LOG_ERROR("Only stereo files supported");
        return;
      }
      if (fmtChunk.wBitsPerSample != 16) {
        LOG_ERROR("Only 16 bit per samples supported");
        return;
      }
    } else if (string{genericChunk.ckId, sizeof(genericChunk.ckId)} == "data") {
      num_data_chunks++;

      // "data" chunk contains the audio samples
      mBuffer = (uint8_t*)malloc(genericChunk.cksize);
      if (!mBuffer) {
        LOG_ERROR("Could not allocate memory");
        return;
      }
      mBufferSize = genericChunk.cksize;

      fres = f_read(&mFile, (void*)mBuffer, mBufferSize, &n_bytes_read);
      if (fres != 0) {
        LOG_ERROR("Failed to read file");
        return;
      }
      if (n_bytes_read != mBufferSize) {
        LOG_ERROR("Didn't read the complete file");
        return;
      }
    } else {
      // Unknown chunk: Just skip it
      DWORD fp = f_tell(&mFile);
      f_lseek(&mFile, fp + genericChunk.cksize);
      num_unknown_chunks++;
    }
  }
  cout << "Done." << endl;
  printf("number of WAV chunks: %ld generic, %ld unknown, %ld fmt, %ld data\n",
         num_generic_chunks,
         num_unknown_chunks,
         num_fmt_chunks,
         num_data_chunks);
}

void FileReader::ReadTXT() {
  cout << "Reading TXT file." << endl;

  // Sanity checks
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
  PrepareBufferData();
  return {mBuffer, mBufferSize};
}
