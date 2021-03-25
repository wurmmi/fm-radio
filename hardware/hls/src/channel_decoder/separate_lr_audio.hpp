/*****************************************************************************/
/**
 * @file    separate_lr_audio.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Separate LR Audio IP header.
 */
/*****************************************************************************/

#ifndef _SEPARATE_AUDIO_HPP
#define _SEPARATE_AUDIO_HPP

#include "fm_global.hpp"

void separate_lr_audio(sample_t const& in_mono,
                       sample_t const& in_lrdiff,
                       sample_t& out_audio_L,
                       sample_t& out_audio_R);

#endif /* _SEPARATE_AUDIO_HPP */
