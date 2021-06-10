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
  uint8_t SubFormat[16];
} wav_fmt_chunk_t;

WavReader::WavReader() {}

WavReader::~WavReader() {}

void WavReader::LoadFile(string const& filename) {
  LOG_INFO("Loading WAV file '%s' ...", filename.c_str());

  // Open the file
  bool success = FileOpen(filename);
  if (!success)
    return;

  /*--- Sanity checks in header ---*/

  // WAV header
  LOG_DEBUG("reading WAV header");
  wav_header_t header;
  size_t n_bytes_read;
  success = FileRead((void*)&header, sizeof(header), n_bytes_read);
  if (!success)
    return;

  if (string{header.riff, sizeof(header.riff)} != "RIFF") {
    LOG_ERROR("Illegal WAV file format, RIFF not found.");
    FileClose();
    return;
  }

  if (string{header.wave, sizeof(header.riff)} != "WAVE") {
    LOG_ERROR("Illegal WAV file format, WAVE not found.");
    FileClose();
    return;
  }
  LOG_DEBUG("WAV header OKAY");

  /*--- Read chunks ---*/
  size_t num_generic_chunks = 0;
  size_t num_unknown_chunks = 0;
  size_t num_fmt_chunks     = 0;
  size_t num_data_chunks    = 0;

  while (1) {
    // Read WAV generic chunk
    wav_generic_chunk_t genericChunk;
    size_t num_bytes_to_read = sizeof(genericChunk);

    LOG_DEBUG("reading a WAV generic chunk");
    success = FileRead((void*)&genericChunk, num_bytes_to_read, n_bytes_read);
    if (!success) {
      if (n_bytes_read != num_bytes_to_read) {
        LOG_WARN("reached EOF (may be acceptable)");
        // Is an acceptable situation in this case
        break;
      }
    }

    num_generic_chunks++;

    wav_fmt_chunk_t fmtChunk;
    if (string{genericChunk.ckId, sizeof(genericChunk.ckId)} == "fmt ") {
      num_fmt_chunks++;

      /* The FMT chunk is compulsory and contains information about
       * the sample format. */
      success = FileRead((void*)&fmtChunk, genericChunk.cksize, n_bytes_read);
      if (!success)
        return;

      /*--- Sanity checks in FMT chunk ---*/
      if (fmtChunk.wFormatTag != 1) {
        LOG_ERROR("Unsupported format");
        FileClose();
        return;
      }
      if (fmtChunk.nChannels != 2) {
        LOG_ERROR("Only stereo files supported");
        FileClose();
        return;
      }
      if (fmtChunk.wBitsPerSample != 16) {
        LOG_ERROR("Only 16 bit per samples supported");
        FileClose();
        return;
      }
    } else if (string{genericChunk.ckId, sizeof(genericChunk.ckId)} == "data") {
      num_data_chunks++;

      /* The DATA chunk contains all the audio samples */
      /** TODO: Use a better concept to free this allocated memory somewhere.
       */
      mBuffer.buffer = new uint8_t[genericChunk.cksize];
      if (!mBuffer.buffer) {
        LOG_ERROR("Could not allocate memory");
        FileClose();
        delete[] mBuffer.buffer;
        mBuffer = {nullptr, 0};
        return;
      }
      mBuffer.size = genericChunk.cksize;

      success = FileRead((void*)mBuffer.buffer, mBuffer.size, n_bytes_read);
      if (!success) {
        delete[] mBuffer.buffer;
        mBuffer = {nullptr, 0};
        return;
      }
    } else {
      LOG_DEBUG("skipping unknown chunk: '%s'", genericChunk.ckId);

      // Advance the file pointer
      success = FileSeek(genericChunk.cksize);
      if (!success)
        return;

      num_unknown_chunks++;
    }
  }

  LOG_INFO("Done.");
  LOG_DEBUG(
      "Read %zu bytes from WAV file '%s'", mBuffer.size, filename.c_str());
  LOG_DEBUG(
      "number of read WAV chunks: "
      "%zu generic (%zu unknown + %zu fmt + %zu data)",
      num_generic_chunks,
      num_unknown_chunks,
      num_fmt_chunks,
      num_data_chunks);

  // PrepareBufferData();
}
