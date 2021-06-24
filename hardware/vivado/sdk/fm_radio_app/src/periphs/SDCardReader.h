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

#include "AudioStreamDMA.h"
#include "FileReader.h"

class SDCardReader {
 private:
  FATFS mFilesystem;
  std::vector<std::string> mFilenames;
  std::string mCurrentlyLoadedFilename;
  bool mMounted;
  FileReader* mFileReader;

  inline static const char* LOGICAL_DRIVE_0 = "0:/";

  bool IsMounted();
  bool FoundFiles();
  std::string GetShortFilename(std::string const& filename);

 public:
  SDCardReader();
  ~SDCardReader();

  bool MountSDCard(uint8_t num_retries = 1);
  void DiscoverFiles();
  bool LoadFile(std::string const& filename);
  bool WriteFile(std::string const& filename, std::vector<uint32_t> data);
  void PrintAvailableFilenames() const;
  DMABuffer GetBuffer();
  std::string const& GetCurrentlyLoadedFilename();
};

#endif /* _SDCARDREADER_H_ */
