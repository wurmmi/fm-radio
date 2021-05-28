/**
 * @file    TxtReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "TxtReader.h"

#include <algorithm>
#include <iostream>

#include "log.h"

using namespace std;

TxtReader::TxtReader() {}

TxtReader::~TxtReader() {}

void TxtReader::LoadFile(string const& filename) {
  LOG_DEBUG("Reading TXT file.");
  LOG_ERROR("NOT IMPLEMENTED YET");

  // Open the file
  FRESULT fres = f_open(&mFile, filename.c_str(), FA_READ);
  if (fres) {
    LOG_ERROR("Error opening file! (error: %d)", fres);
    return;
  }

  /*--- Sanity checks ---*/
  // TODO

  f_close(&mFile);

  LOG_DEBUG("Done.");
  LOG_DEBUG("Read %ld bytes from TXT file '%s'", mBufferSize, filename.c_str());

  PrepareBufferData();
}
