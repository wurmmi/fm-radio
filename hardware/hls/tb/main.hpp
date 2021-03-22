/*****************************************************************************/
/**
 * @file    fm_receiver.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver IP header.
 */
/*****************************************************************************/

#ifndef _MAIN_HPP
#define _MAIN_HPP

#include <fstream>
#include <vector>

#include "fm_global.hpp"

std::vector<sample_t> loadDataFromFile(std::string filename,
                                       uint32_t num_samples) {
  std::ifstream fd;
  fd.open(filename, std::ios::in);
  if (!fd.is_open()) {
    throw std::runtime_error("Failed to open file '" + filename + "'");
  }

  std::vector<sample_t> data;

  sample_t value = 0;
  while (fd >> value) {
    data.emplace_back(value);

    // Stop, if enough samples were read
    if (data.size() >= num_samples)
      break;
  }
  fd.close();

  // Check if enough samples were read
  size_t num_read = data.size();
  if (num_read < num_samples) {
    const std::string msg = "File '" + filename +
                            "' contains less elements than requested!\n" +
                            std::to_string(num_read) + " actual < " +
                            std::to_string(num_samples) + " requested";
    throw std::runtime_error(msg);
  }

  return data;
}

#endif /* _MAIN_HPP */
