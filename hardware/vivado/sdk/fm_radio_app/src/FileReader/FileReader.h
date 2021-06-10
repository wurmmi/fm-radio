/**
 * @file    FileReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FILEREADER_H_
#define _FILEREADER_H_

#ifdef __CSIM__
#pragma message "__CSIM__ IS DEFINED !!###########################"
#else
#include <ff.h>
#endif

#include <string>

typedef struct {
  uint8_t* buffer;
  uint32_t bufferSize;
} DMABuffer;

enum class FileType { UNKNOWN, WAV, TXT };

class FileReader {
 private:
 protected:
  DMABuffer mBuffer = {nullptr, 0};
#if __CSIM__
#else
  FIL mFile;
#endif

  void PrepareBufferData();

 public:
  FileReader();
  ~FileReader();

  static FileType GetFileType(std::string const& filename);

  virtual void LoadFile(std::string const& filename) = 0;
  DMABuffer GetBuffer();
};

#endif /* _FILEREADER_H_ */
