#include "fir.hpp"

sample_t fir_coeffs_c[FIR_N] = {0.180617,
                                0.045051,
                                0.723173,
                                0.347438,
                                0.660617,
                                0.383869,
                                0.627347,
                                0.021650,
                                0.910570,
                                0.800559,
                                0.745847,
                                0.813113,
                                0.383306,
                                0.617279,
                                0.575495,
                                0.530052};

void fir_filter(hls::stream<sample_t> &in,
                hls::stream<sample_t> &out,
                sample_t coeff[NUM_SAMPLES]) {
#pragma HLS INTERFACE axis port = in
#pragma HLS INTERFACE axis port = out

  sample_t acc, mult;
  static sample_t shift_reg[FIR_N];
#pragma HLS ARRAY_PARTITION variable = shift_reg complete dim = 0

Samples_loop:
  for (int s = 0; s < NUM_SAMPLES; s++) {
  Shift_Accum_Loop:
    for (int i = FIR_N - 1; i >= 0; i--) {
#pragma HLS PIPELINE II = 1
      // 	------	Shift Register	------
      if (i == 0) {
        shift_reg[0] = in.read();
      } else {
        if (s == 0)  // If 1st sample, initialise Shift Register with zeros
          shift_reg[i] = 0.0;
        else  // Else, Shift Register normal operation
          shift_reg[i] = shift_reg[i - 1];
      }
      //	------	Multiply by coefficient	------
      mult = shift_reg[i] * coeff[i];
      //	------	Accumulate	------
      if (i == FIR_N - 1)
        acc = mult;
      else
        acc = acc + mult;
      //	------	Write output result	------
      if (i == 0)
        out.write((sample_t)acc);
    }
  }
}
