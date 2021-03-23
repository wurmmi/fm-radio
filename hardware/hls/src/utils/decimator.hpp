/*****************************************************************************/
/**
 * @file    decimator.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Decimator IP header.
 */
/*****************************************************************************/

#ifndef _DECIMATOR_HPP
#define _DECIMATOR_HPP

#include "fm_global.hpp"

const uint8_t osr_rx_c = 8;

void decimator(sample_t const& in, sample_t& out, bool& valid);

#endif /* _DECIMATOR_HPP */
