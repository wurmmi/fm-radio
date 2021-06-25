/**
 * @file    FileReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _FILEREADER_H_
#define _FILEREADER_H_

#if defined(__CSIM__) || defined(__RTL_SIMULATION__)
#include <cstdio>
#else
#include <ff.h>
#endif

#include <string>
#include <vector>

typedef struct {
  uint8_t* buffer;
  size_t size;
} DMABuffer;

enum class FileType { UNKNOWN, WAV, TXT };
enum class FileOpenMode { READ, WRITE };

class FileReader {
 private:
  bool mFileIsOpen;

 protected:
  DMABuffer mBuffer = {nullptr, 0};
#if defined(__CSIM__) || defined(__RTL_SIMULATION__)
  FILE* mFile;
#else
  FIL mFile;
#endif

  void SwapLeftAndRight();

 public:
  FileReader();
  ~FileReader();

  bool FileOpen(std::string const& filename, FileOpenMode openMode);
  void FileClose();
  bool FileRead(void* target_buf,
                size_t num_bytes_to_read,
                size_t& n_bytes_read);
  bool FileWrite(std::vector<uint32_t> data);
  bool FileSeek(size_t num_bytes_offset);

  static FileType GetFileType(std::string const& filename);

  virtual bool LoadFile(std::string const& filename);
  DMABuffer GetBuffer();
};

#endif /* _FILEREADER_H_ */
