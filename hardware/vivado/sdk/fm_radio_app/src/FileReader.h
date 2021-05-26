/**
 * @file    FileReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FILEREADER_H_
#define _FILEREADER_H_

#include <ff.h>

#include <string>
#include <vector>

#include "AudioStreamDMA.h"

enum class FileType { UNKNOWN, WAV, TXT };

class FileReader {
 private:
  FIL mFile;
  uint8_t* mBuffer     = nullptr;
  uint32_t mBufferSize = 0;

  FileType GetFileType(std::string const& filename);
  void ReadWAV();
  void ReadTXT();

 public:
  FileReader();
  ~FileReader();

  void LoadFile(std::string const& filename);
  DMABuffer GetBuffer();
};

#endif /* _FILEREADER_H_ */
