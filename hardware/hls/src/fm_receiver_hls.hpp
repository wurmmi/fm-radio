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

#ifndef GIT_HASH
#warning GIT_HASH is undefined!
#define GIT_HASH "undefined"
#endif

#ifndef BUILD_TIME
#warning BUILD_TIME is undefined!
#define BUILD_TIME "4711"
#endif

typedef struct {
  sample_t L;
  sample_t R;
} audio_sample_t;

void fm_receiver_hls(hls::stream<iq_sample_t>& iq_in,
                     hls::stream<audio_sample_t>& audio_out,
                     uint8_t led_ctrl,
                     char const* git_hash,
                     char const* build_time,
                     uint8_t& led_out);

#endif /* _FM_RECEIVER_HLS_HPP */
