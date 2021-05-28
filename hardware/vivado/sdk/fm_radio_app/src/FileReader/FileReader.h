/**
 * @file    FileReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FILEREADER_H_
#define _FILEREADER_H_

#include <ff.h>

#include <string>

#include "AudioStreamDMA.h"

enum class FileType { UNKNOWN, WAV, TXT };

class FileReader {
 private:
 protected:
  FIL mFile;
  uint8_t* mBuffer     = nullptr;
  uint32_t mBufferSize = 0;

  void PrepareBufferData();

 public:
  FileReader();
  ~FileReader();

  static FileType GetFileType(std::string const& filename);

  virtual void LoadFile(std::string const& filename) = 0;
  DMABuffer GetBuffer();
};

#endif /* _FILEREADER_H_ */
