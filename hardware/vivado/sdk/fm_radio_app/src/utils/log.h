/**
 * @file    log.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   log helper functions
 */

#ifndef _LOG_H_
#define _LOG_H_

#include <iostream>

#define ENABLE_DEBUG_MSG 1

#define LOG_ERROR(format, ...) \
  printf(                      \
      "ERROR: (%s::%s()) " format "\n", __FILE__, __FUNCTION__, ##__VA_ARGS__)

#define LOG_WARN(format, ...) printf("WARN : " format "\n", ##__VA_ARGS__)
#define LOG_INFO(format, ...) printf("INFO : " format "\n", ##__VA_ARGS__)

#if ENABLE_DEBUG_MSG == 1
#define LOG_DEBUG(format, ...) printf("DEBUG: " format "\n", ##__VA_ARGS__)
#else
#define LOG_DEBUG(format, ...) void();
#endif

#endif /* _LOG_H_ */
