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
  u32 riffSize;
  char wave[4];
} wav_header_t;

typedef struct {
  char ckId[4];
  u32 cksize;
} wav_generic_chunk_t;

typedef struct {
  u16 wFormatTag;
  u16 nChannels;
  u32 nSamplesPerSec;
  u32 nAvgBytesPerSec;
  u16 nBlockAlign;
  u16 wBitsPerSample;
  u16 cbSize;
  u16 wValidBitsPerSample;
  u32 dwChannelMask;
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

  switch (fileType) {
    case FileType::WAV:
      ReadWAV();
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

  if (string(header.riff) != "RIFF") {
    LOG_ERROR("Illegal WAV file format, RIFF not found.");
    return;
  }

  if (string(header.wave) != "WAVE") {
    LOG_ERROR("Illegal WAV file format, WAVE not found.");
    return;
  }

  /*--- Read chunks ---*/
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

    wav_fmt_chunk_t fmtChunk;
    if (string(genericChunk.ckId) == "fmt ") {
      // "fmt" chunk is compulsory and contains information about the sample
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
    } else if (string(genericChunk.ckId) == "data") {
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
    }
  }
  cout << "Done." << endl;
}

void FileReader::ReadTXT() {
  cout << "Reading TXT file." << endl;

  // Sanity checks
}

DMABuffer FileReader::GetBuffer() {
  return {mBuffer, mBufferSize};
}
