/**
 * @file    FileReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FILEREADER_H_
#define _FILEREADER_H_

#ifdef __CSIM__
#include <cstdio>
#else
#include <ff.h>
#endif

#include <string>

typedef struct {
  uint8_t* buffer;
  size_t size;
} DMABuffer;

enum class FileType { UNKNOWN, WAV, TXT };

class FileReader {
 private:
 protected:
  DMABuffer mBuffer = {nullptr, 0};
#ifdef __CSIM__
  FILE* mFile;
#else
  FIL mFile;
#endif

  void PrepareBufferData();
  bool FileOpen(std::string const& filename);
  void FileClose();
  bool FileRead(void* target_buf,
                size_t num_bytes_to_read,
                size_t& n_bytes_read);
  bool FileSeek(size_t num_bytes_offset);

 public:
  FileReader();
  ~FileReader();

  static FileType GetFileType(std::string const& filename);

  virtual void LoadFile(std::string const& filename) = 0;
  DMABuffer GetBuffer();
};

#endif /* _FILEREADER_H_ */
