/**
 * @file    FileReader.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Class implementation
 */

#include "FileReader.h"

#include <algorithm>
#include <iostream>

using namespace std;

FileReader::FileReader() {
  mMounted = false;
}

FileReader::~FileReader() {}

FileType FileReader::GetFileType(string& filename) {
  transform(filename.begin(), filename.end(), ::tolower);

  if (filename.find(".txt") != string::npos) {
    return FileType::TXT;
  }
  if (filename.find(".wav") != string::npos) {
    return FileType::WAV;
  }

  return FileType::UNKNOWN;
}

void FileReader::LoadFile(string& filename) {
  // Handle file depending on its type
  FileType fileType = GetFileType(filename);
  if (fileType == FileType::UNKNOWN) {
    cerr << "Unknown filetype of file: " << filename << endl;
    return;
  }

  // Open the file
  FIL file;
  FRESULT fres = f_open(&file, filename.c_str(), FA_READ);
  if (fres) {
    cerr << "Error opening file! (error: " << fres << ")" << endl;
    return;
  }

  switch (fileType) {
    case FileType::WAV:
      ReadWAV(file);
      break;
    case FileType::TXT:
      ReadTXT(file);
      break;

    case FileType::UNKNOWN:
    default:
      break;
  }
}

void FileReader::ReadWAV(FIL& file) {
  cout << "Reading WAV file." << endl;

  // Sanity checks
}

void FileReader::ReadTXT(FIL& file) {
  cout << "Reading TXT file." << endl;

  // Sanity checks
}
