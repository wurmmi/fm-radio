/*****************************************************************************/
/**
 * @file    DataWriter.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Save data for usage in testbench.
 */
/*****************************************************************************/

#ifndef _DATAWRITER_HPP
#define _DATAWRITER_HPP

#include <fstream>
#include <iomanip>
#include <vector>

#include "fm_global.hpp"

using data_vec_t = std::vector<sample_t>;

class DataWriter {
 private:
  std::ofstream ofs;
  const std::string folder_output = "./output/";
  data_vec_t data;

 public:
  DataWriter(std::string const& filename) {
    std::cout << "DataWriter::CTOR" << std::endl;

    std::string filepath = folder_output + filename;
    ofs.open(filepath, std::ios::out);
    if (!ofs.is_open()) {
      std::cout << "DataWriter::CTOR failed to open file" << std::endl;
      throw std::runtime_error("Failed to open file'" + filepath);
    }
  }
  ~DataWriter() {
    std::cout << "DataWriter::DTOR" << std::endl;
    ofs.close();
  }

  void write(sample_t value) {
    // Write to file
    ofs << std::fixed << std::setw(FP_WIDTH + 3)
        << std::setprecision(FP_WIDTH_FRAC) << value.to_float() << std::endl;

    // Store in local vector
    data.emplace_back(value);
  }
};

#endif /* _DATAWRITER_HPP */