/*****************************************************************************/
/**
 * @file    channel_decoder.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Channel Decoder IP header.
 */
/*****************************************************************************/

#ifndef _CHANNEL_DECODER_HPP
#define _CHANNEL_DECODER_HPP

#include <hls_stream.h>

#include "fm_global.hpp"

audio_sample_t channel_decoder(hls::stream<sample_t>& in_sample);

#endif /* _CHANNEL_DECODER_HPP */
