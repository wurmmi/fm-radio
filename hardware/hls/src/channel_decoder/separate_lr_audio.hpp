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

audio_sample_t separate_lr_audio(sample_t const& in_mono,
                                 sample_t const& in_lrdiff);

#endif /* _SEPARATE_AUDIO_HPP */
