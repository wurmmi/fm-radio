/*****************************************************************************/
/**
 * @file    main.cpp
 * @author  Michael Wurm <wurm.michael95@gmail.com>
 * @brief   Implementation for testbench.
 */
/*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include "fm_receiver.hpp"

int main()
{
	hls::stream<axi_stream_t> top_in_hw("top_in_hw");
	hls::stream<axi_stream_t> top_out_hw("top_out_hw");
	hls::stream<axi_stream_t> out_gold("out_gold");

	inp_data_t signal[NUM_SAMPLES];
	out_data_t reference[NUM_SAMPLES];

	FILE *fp1, *fp2;
	float val1, val2;
	int err = 0;

	// LOAD INPUT DATA  AND REFERENCE RESULTS
	fp1 = fopen("./data/input.dat", "r");
	fp2 = fopen("./data/ref_res.dat", "r");
	for (int i = 0; i < NUM_SAMPLES; i++)
	{
		fscanf(fp1, "%f\n", &val1);
		signal[i] = (inp_data_t)val1;
		fscanf(fp2, "%f\n", &val2);
		reference[i] = (out_data_t)val2;
	}
	fclose(fp1);
	fclose(fp2);

	// convert input data array into an input stream
	getArray2Stream_axi<NUM_SAMPLES, DATA_WIDTH_IN, axi_stream_t, inp_data_t>(signal, top_in_hw);
	// convert golden data array into a golden stream
	getArray2Stream_axi<NUM_SAMPLES, DATA_WIDTH_OUT, axi_stream_t, out_data_t>(reference, out_gold);
	// CALL DESIGN UNDER TEST
	top(top_in_hw, top_out_hw);
	// CHECK RESULTS
	err += checkStreamEqual_axi<axi_stream_t, out_data_t>(top_out_hw, out_gold, false);
	printf("%s\n", (err == 0) ? "\r\n\t--- PASSED ---\r\n" : "\r\n\t--- FAILED ---\r\n");
	//	------	Execute a second filter run
	// convert input data array into an input stream
	getArray2Stream_axi<NUM_SAMPLES, DATA_WIDTH_IN, axi_stream_t, inp_data_t>(signal, top_in_hw);
	// convert golden data array into a golden stream
	getArray2Stream_axi<NUM_SAMPLES, DATA_WIDTH_OUT, axi_stream_t, out_data_t>(reference, out_gold);
	// CALL DESIGN UNDER TEST
	top(top_in_hw, top_out_hw);
	// CHECK RESULTS
	err += checkStreamEqual_axi<axi_stream_t, out_data_t>(top_out_hw, out_gold, false);
	printf("%s\n", (err == 0) ? "\r\n\t--- PASSED ---\r\n" : "\r\n\t--- FAILED ---\r\n");

	return err;
}
