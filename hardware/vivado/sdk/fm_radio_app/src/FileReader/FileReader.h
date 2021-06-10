/**
 * @file    FileReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FILEREADER_H_
#define _FILEREADER_H_

#ifndef __CSIM__
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
  FIL mFile;
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
