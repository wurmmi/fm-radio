/**
 * @file    TxtReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "TxtReader.h"

#include <ff.h>

#include <algorithm>
#include <fstream>
#include <iostream>

#include "log.h"

using namespace std;

TxtReader::TxtReader() {}

TxtReader::~TxtReader() {}

bool TxtReader::LoadFile(string const& filename) {
  /* Get file size info */
  FILINFO fileInfo;
  FRESULT fres = f_stat(filename.c_str(), &fileInfo);
  if (fres) {
    LOG_ERROR("Error opening file with f_stat! (error: %d)", fres);
    return false;
  }
  uint32_t fileSize = fileInfo.fsize;

  /* Open the file */
  fres = f_open(&mFile, filename.c_str(), FA_READ);
  if (fres) {
    LOG_ERROR("Error opening file! (error: %d)", fres);
    return false;
  }

  /* Load entire file at once */
  size_t n_bytes_read;
  /** TODO: Use a better concept to free this allocated memory somewhere. */
  mBuffer.buffer = new uint8_t[fileSize];

  fres = f_read(&mFile, (void*)mBuffer.buffer, fileSize, &n_bytes_read);
  if (fres) {
    LOG_ERROR("Error reading file! (error: %d)", fres);
    f_close(&mFile);
    delete[] mBuffer.buffer;
    mBuffer = {nullptr, 0};
    return false;
  }

  /* Sanity checks */
  if (n_bytes_read != fileSize) {
    LOG_ERROR("Error reading file! (fileSize = %ld, n_bytes_read = %d)",
              fileSize,
              (int)n_bytes_read);
    f_close(&mFile);
    delete[] mBuffer.buffer;
    mBuffer = {nullptr, 0};
    return false;
  }
  mBuffer.size = fileSize;

  /** TODO: convert binary buffer to integers */

  f_close(&mFile);

  LOG_DEBUG("Done.");
  LOG_DEBUG(
      "Read %zu bytes from TXT file '%s'", mBuffer.size, filename.c_str());

  return true;
}