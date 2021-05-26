/**
 * @file    log.h
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   log helper functions
 */

#ifndef _LOG_H_
#define _LOG_H_

#include <iostream>

void log_error(std::string const& func, std::string const& msg);

#define LOG_ERROR(msg) log_error(__PRETTY_FUNCTION__, msg)

#endif /* _LOG_H_ */
