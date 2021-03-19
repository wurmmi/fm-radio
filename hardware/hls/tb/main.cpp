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
	hls::stream<axi_stream_element_t> top_in_hw("top_in_hw");
	hls::stream<axi_stream_element_t> top_out_hw("top_out_hw");
	hls::stream<axi_stream_element_t> out_gold("out_gold");

	sample_t signal[NUM_SAMPLES];
	sample_t reference[NUM_SAMPLES];

	FILE *fp1, *fp2;
	float val1, val2;
	int err = 0;

	// LOAD INPUT DATA  AND REFERENCE RESULTS
	fp1 = fopen("./data/input.dat", "r");
	fp2 = fopen("./data/ref_res.dat", "r");
	for (int i = 0; i < NUM_SAMPLES; i++)
	{
		fscanf(fp1, "%f\n", &val1);
		signal[i] = (sample_t)val1;
		fscanf(fp2, "%f\n", &val2);
		reference[i] = (sample_t)val2;
	}
	fclose(fp1);
	fclose(fp2);

	// convert input data array into an input stream
	getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(signal, top_in_hw);
	// convert golden data array into a golden stream
	getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(reference, out_gold);
	// CALL DESIGN UNDER TEST
	fm_receiver(top_in_hw, top_out_hw);
	// CHECK RESULTS
	err += checkStreamEqual_axi<axi_stream_element_t, sample_t>(top_out_hw, out_gold, false);
	printf("%s\n", (err == 0) ? "\r\n\t--- PASSED ---\r\n" : "\r\n\t--- FAILED ---\r\n");
	//	------	Execute a second filter run
	// convert input data array into an input stream
	getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(signal, top_in_hw);
	// convert golden data array into a golden stream
	getArray2Stream_axi<NUM_SAMPLES, FP_WIDTH, axi_stream_element_t, sample_t>(reference, out_gold);
	// CALL DESIGN UNDER TEST
	fm_receiver(top_in_hw, top_out_hw);
	// CHECK RESULTS
	err += checkStreamEqual_axi<axi_stream_element_t, sample_t>(top_out_hw, out_gold, false);
	printf("%s\n", (err == 0) ? "\r\n\t--- PASSED ---\r\n" : "\r\n\t--- FAILED ---\r\n");

	return err;
}
