/**
 * @file    WavReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _WAVREADER_H_
#define _WAVREADER_H_

#include <ff.h>

#include <string>

#include "FileReader.h"

class WavReader : public FileReader {
 private:
 public:
  WavReader();
  ~WavReader();

  void LoadFile(std::string const& filename) override;
};

#endif /* _WAVREADER_H_ */
