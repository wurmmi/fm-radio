/*****************************************************************************/
/**
 * @file    fm_receiver_hls.hpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   FM Receiver top-level wrapper header.
 */
/*****************************************************************************/

#ifndef _FM_RECEIVER_HLS_HPP
#define _FM_RECEIVER_HLS_HPP

#include <hls_stream.h>

#include "fm_global.hpp"

typedef struct {
  sample_t L;
  sample_t R;
} audio_sample_t;

void fm_receiver_hls(hls::stream<iq_sample_t>& iq_in,
                     hls::stream<audio_sample_t>& audio_out,
                     uint8_t led_ctrl,
                     char git_hash[8],
                     char build_time[13],
                     uint8_t& led_out);

#endif /* _FM_RECEIVER_HLS_HPP */
