/**
 * @file    log.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   log helper functions
 */

#ifndef _LOG_H_
#define _LOG_H_

#include <iostream>

#define LOG_ERROR(...) printf("ERROR %s: %s", __PRETTY_FUNCTION__, __VA_ARGS__)
#define LOG_INFO(...)  printf("INFO  %s: %s", __PRETTY_FUNCTION__, __VA_ARGS__)

#endif /* _LOG_H_ */
