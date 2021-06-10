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

void TxtReader::LoadFile(string const& filename) {
  /* Get file size info */
  FILINFO fileInfo;
  FRESULT fres = f_stat(filename.c_str(), &fileInfo);
  if (fres) {
    LOG_ERROR("Error opening file with f_stat! (error: %d)", fres);
    return;
  }
  uint32_t fileSize = fileInfo.fsize;

  /* Open the file */
  fres = f_open(&mFile, filename.c_str(), FA_READ);
  if (fres) {
    LOG_ERROR("Error opening file! (error: %d)", fres);
    return;
  }

  /* Load entire file at once */
  UINT n_byte_read = 0;
  /** TODO: Use a better concept to free this allocated memory somewhere. */
  mBuffer.buffer = new uint8_t[fileSize];

  fres = f_read(&mFile, (void*)mBuffer.buffer, fileSize, &n_byte_read);
  if (fres) {
    LOG_ERROR("Error reading file! (error: %d)", fres);
    f_close(&mFile);
    delete[] mBuffer.buffer;
    return;
  }

  /* Sanity checks */
  if (n_byte_read != fileSize) {
    LOG_ERROR("Error reading file! (fileSize = %ld, n_byte_read = %d)",
              fileSize,
              (int)n_byte_read);
    f_close(&mFile);
    delete[] mBuffer.buffer;
    return;
  }
  mBufferSize = fileSize;

  /** TODO: convert binary buffer to integers */

  f_close(&mFile);

  LOG_DEBUG("Done.");
  LOG_DEBUG("Read %ld bytes from TXT file '%s'", mBufferSize, filename.c_str());

  PrepareBufferData();
}
