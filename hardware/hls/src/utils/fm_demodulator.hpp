/*****************************************************************************/
/**
 * @file    fm_demodulator.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Demodulator IP header.
 */
/*****************************************************************************/

#ifndef _FM_DEMODULATOR_HPP
#define _FM_DEMODULATOR_HPP

#include "fm_global.hpp"

sample_t fm_demodulator(iq_sample_t const& iq);

#endif /* _FM_DEMODULATOR_HPP */
