/**
 * @file    WavReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "WavReader.h"

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

WavReader::WavReader() {}

WavReader::~WavReader() {}

void WavReader::LoadFile(string const& filename) {
  LOG_DEBUG("Reading WAV file.");

  // Open the file
  FRESULT fres = f_open(&mFile, filename.c_str(), FA_READ);
  if (fres) {
    LOG_ERROR("Error opening file! (error: %d)", fres);
    return;
  }

  /*--- Sanity checks ---*/

  // WAV header
  wav_header_t header;
  UINT n_bytes_read;
  fres = f_read(&mFile, (void*)&header, sizeof(header), &n_bytes_read);
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

      // "data" chunk contains all the audio samples
      /** TODO: need to free this allocated memory somewhere! */
      mBuffer = new uint8_t[genericChunk.cksize];
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
      LOG_DEBUG("skipping unknown chunk: %s", genericChunk.ckId);

      // advance the file pointer
      DWORD fp = f_tell(&mFile);
      f_lseek(&mFile, fp + genericChunk.cksize);
      num_unknown_chunks++;
    }
  }
  f_close(&mFile);

  LOG_DEBUG("Done.");
  LOG_DEBUG("Read %ld bytes from WAV file '%s'", mBufferSize, filename.c_str());
  LOG_DEBUG("number of WAV chunks: %ld generic, %ld unknown, %ld fmt, %ld data",
            num_generic_chunks,
            num_unknown_chunks,
            num_fmt_chunks,
            num_data_chunks);

  PrepareBufferData();
}
