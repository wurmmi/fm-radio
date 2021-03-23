/*****************************************************************************/
/**
 * @file    channel_decoder.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Channel Decoder IP header.
 */
/*****************************************************************************/

#ifndef _CHANNEL_DECODER_HPP
#define _CHANNEL_DECODER_HPP

#include "fm_global.hpp"

void channel_decoder(sample_t const& sample_in,
                     sample_t& out_audio_L,
                     sample_t& out_audio_R);

#endif /* _CHANNEL_DECODER_HPP */
