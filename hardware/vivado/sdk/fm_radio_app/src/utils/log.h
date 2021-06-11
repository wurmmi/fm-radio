/**
 * @file    log.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Log functions for pretty logging
 */

#ifndef _LOG_H_
#define _LOG_H_

#include <iostream>

#define ENABLE_DEBUG_MSG 1

// clang-format off
#define _LOG_ERROR(format, ...) printf("ERROR: (%s::%s()) " format "\n", __FILE__, __FUNCTION__, ##__VA_ARGS__)
#define _LOG_WARN(format, ...)  printf("WARN : "            format "\n", ##__VA_ARGS__)
#define _LOG_INFO(format, ...)  printf("INFO : "            format "\n", ##__VA_ARGS__)
#define _LOG_DEBUG(format, ...) printf("DEBUG: "            format "\n", ##__VA_ARGS__)

#ifdef __CSIM__
/** NOTE: Just adding a fflush() after the printf()... */
#define LOG_ERROR(format, ...) ({ _LOG_ERROR(format, ##__VA_ARGS__); fflush(stdout); })
#define LOG_WARN(format, ...)  ({ _LOG_WARN(format, ##__VA_ARGS__);  fflush(stdout); })
#define LOG_INFO(format, ...)  ({ _LOG_INFO(format, ##__VA_ARGS__);  fflush(stdout); })

#if ENABLE_DEBUG_MSG == 1
#define LOG_DEBUG(format, ...) ({ _LOG_DEBUG(format, ##__VA_ARGS__); fflush(stdout); })
#else
#define LOG_DEBUG(format, ...) void();
#endif
#else /* __CSIM__ not defined */
#define LOG_ERROR(format, ...) ({ _LOG_ERROR(format, ##__VA_ARGS__); })
#define LOG_WARN(format, ...)  ({ _LOG_WARN(format, ##__VA_ARGS__);  })
#define LOG_INFO(format, ...)  ({ _LOG_INFO(format, ##__VA_ARGS__);  })

#if ENABLE_DEBUG_MSG == 1
#define LOG_DEBUG(format, ...) _LOG_DEBUG(format, ##__VA_ARGS__);
#else
#define LOG_DEBUG(format, ...) void();
#endif
#endif /* __CSIM__ */

// clang-format on
#endif /* _LOG_H_ */
