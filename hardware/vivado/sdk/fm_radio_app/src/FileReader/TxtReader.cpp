/**
 * @file    TxtReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "TxtReader.h"

// clang-format off

#include <algorithm>
#include <fstream>
#include <iostream>

#include "fm_global.hpp"
#include "log.h"

#include <ff.h>
// clang-format on

using namespace std;

TxtReader::TxtReader() {
  sample_t sample = 0.7;
}

TxtReader::~TxtReader() {}

void TxtReader::LoadFile(string const& filename) {
  LOG_DEBUG("Reading TXT file.");

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

  fres = f_read(&mFile, (void*)mBuffer, fileSize, &n_byte_read);
  if (fres) {
    LOG_ERROR("Error reading file! (error: %d)", fres);
    return;
  }

  /* Sanity checks */
  if (n_byte_read != fileSize) {
    LOG_ERROR("Error reading file! (fileSize = %ld, n_byte_read = %d)",
              fileSize,
              (int)n_byte_read);
    return;
  }

  /** TODO: convert binary buffer to integers */

  f_close(&mFile);

  LOG_DEBUG("Done.");
  LOG_DEBUG("Read %ld bytes from TXT file '%s'", mBufferSize, filename.c_str());

  PrepareBufferData();
}
