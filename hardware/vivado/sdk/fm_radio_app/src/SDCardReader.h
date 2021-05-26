/**
 * @file    SDCardReader.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class definition
 */

#ifndef _SDCARDREADER_H_
#define _SDCARDREADER_H_

#include <ff.h>

#include <string>
#include <vector>

#include "FileReader.h"

class SDCardReader {
 private:
  FATFS mFilesystem;
  std::vector<std::string> mFilenames;
  bool mMounted;
  FileReader mFileReader;

  inline static const char* LOGICAL_DRIVE_0 = "0:/";

  bool IsMountedAndFoundFiles();

 public:
  SDCardReader();
  ~SDCardReader();

  bool MountSDCard(uint8_t num_retries);
  void DiscoverFiles();
  void LoadFile(std::string& filename);
  void PrintAvailableFilenames() const;
};

#endif /* _SDCARDREADER_H_ */
