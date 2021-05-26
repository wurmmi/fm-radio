/**
 * @file    log.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   log helper functions
 */

#include "log.h"

static void log_error(std::string const& func, std::string const& msg) {
  printf("%s: %s\n", func, msg);
}
