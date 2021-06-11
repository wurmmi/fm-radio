/*****************************************************************************/
/**
 * @file    separate_lr_audio.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Separate LR Audio IP implementation.
 */
/*****************************************************************************/

#include "separate_lr_audio.hpp"

using namespace std;

void separate_lr_audio(sample_t const& in_mono,
                       sample_t const& in_lrdiff,
                       audio_sample_t& out_audio) {
  // Compute L and R
  sample_t audio_L = in_mono + in_lrdiff;
  sample_t audio_R = in_mono - in_lrdiff;

  // Output
  out_audio = {audio_L, audio_R};
}
