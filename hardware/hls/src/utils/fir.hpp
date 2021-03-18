#ifndef _FIR_H
#define _FIR_H

#include <ap_fixed.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "fm_global.hpp"

#define FIR_N       16
#define NUM_SAMPLES 1024

#define ERROR_TOLERANCE 0.1

void fir_filter(hls::stream<sample_t> &in,
                hls::stream<sample_t> &out,
                sample_t coeff[NUM_SAMPLES]);

#endif /* _FIR_H */
