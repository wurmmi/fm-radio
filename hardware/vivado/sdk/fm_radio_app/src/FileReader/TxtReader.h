/**
 * @file    TxtReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _TXTREADER_H_
#define _TXTREADER_H_

#include <string>

#include "FileReader.h"

class TxtReader : public FileReader {
 private:
 public:
  TxtReader();
  ~TxtReader();

  void LoadFile(std::string const& filename) override;
};

#endif /* _TXTREADER_H_ */
