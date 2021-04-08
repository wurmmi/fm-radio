/*****************************************************************************/
/**
 * @file    strobe_gen.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Strobe Generator IP header.
 */
/*****************************************************************************/

#ifndef _STROBE_GEN_HPP
#define _STROBE_GEN_HPP

#include <stdint.h>

const uint8_t num_wait_cycles_c = 15;

bool strobe_gen();

#endif /* _STROBE_GEN_HPP */
