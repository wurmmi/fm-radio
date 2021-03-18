#ifndef _FIR_H
#define _FIR_H

#include <ap_fixed.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "fm_global.hpp"

#define FIR_N 16

void fir_filter(hls::stream<sample_t> &in,
                hls::stream<sample_t> &out,
                sample_t coeff[NUM_SAMPLES]);

#endif /* _FIR_H */
