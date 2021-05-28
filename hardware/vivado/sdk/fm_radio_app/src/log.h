/**
 * @file    log.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   log helper functions
 */

#ifndef _LOG_H_
#define _LOG_H_

#include <iostream>

#define LOG_ERROR(format, ...) \
  printf("ERROR %s/%s" format "\n", __FILE__, __FUNCTION__, ##__VA_ARGS__)
#define LOG_INFO(format, ...) \
  printf("INFO %s/%s" format "\n", __FILE__, __FUNCTION__, ##__VA_ARGS__)

#endif /* _LOG_H_ */
