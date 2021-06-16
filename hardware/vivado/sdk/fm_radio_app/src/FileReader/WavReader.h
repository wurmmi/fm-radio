/**
 * @file    WavReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _WAVREADER_H_
#define _WAVREADER_H_

#include <string>

#include "FileReader.h"

class WavReader : public FileReader {
 private:
 public:
  WavReader();
  ~WavReader();

  bool LoadFile(std::string const& filename) override;
};

#endif /* _WAVREADER_H_ */
