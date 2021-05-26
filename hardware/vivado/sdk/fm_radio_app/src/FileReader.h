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

enum class FileType { UNKNOWN, WAV, TXT };

class FileReader {
 private:
  FATFS mFilesystem;
  std::vector<std::string> mFilenames;
  bool mMounted;

  FileType GetFileType(std::string& filename);
  void ReadWAV(FIL& file);
  void ReadTXT(FIL& file);

 public:
  FileReader();
  ~FileReader();

  void LoadFile(std::string& filename);
};

#endif /* _FILEREADER_H_ */
