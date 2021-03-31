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

void decimator(sample_t const& in_sample, sample_t& out, bool& valid);

#endif /* _DECIMATOR_HPP */
