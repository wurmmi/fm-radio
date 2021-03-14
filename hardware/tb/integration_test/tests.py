################################################################################
# File        : test.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testcases for the FM Receiver IP.
################################################################################

import time

import cocotb
import matplotlib.pyplot as plt
import numpy as np
from cocotb.clock import Clock
from cocotb.generators import repeat
from cocotb.generators.bit import bit_toggler
from cocotb.triggers import RisingEdge, Timer
from fixed_point import *

from fm_tb import FM_TB


@cocotb.test()
async def fir_filter_test(dut):
    """
    Load test data from files and send them through the DUT.
    Compare input and output afterwards.
    """
    EnablePlots = False

    timestamp_start = time.time()

    ###
    # Constants
    ###

    # Number of samples to process
    num_samples = 150

    # Sample rate (set according to files in folder sim/matlab/verification_data/)
    fs_rx_c = 120e3

    # Fixed point settings
    fp_width_c = 32
    fp_width_frac_c = 31

    ###
    # Load data from files
    ###
    filename = "../../../sim/matlab/verification_data/rx_fmChannelData.txt"
    data_i = []
    with open(filename) as fd:
        val_count = 0
        for line in fd:
            data_i.append(float(line.strip('\n')))
            val_count += 1
            # Stop after required number of samples
            if val_count >= num_samples:
                break

    # Convert to fixed point and back to int
    data_i_fp = to_fixed_point(data_i, fp_width_c, fp_width_frac_c)
    data_i_int = fixed_to_int(data_i_fp)

    filename = "../../../sim/matlab/verification_data/rx_pilot.txt"
    data_o_gold = []
    with open(filename) as fd:
        val_count = 0
        for line in fd:
            data_o_gold.append(float(line.strip('\n')))
            val_count += 1
            # Stop after required number of samples
            if val_count >= num_samples:
                break

    # Convert to fixed point
    data_o_gold_fp = to_fixed_point(data_o_gold, fp_width_c, fp_width_frac_c)

    ###
    # Prepare environment
    ###
    tb = FM_TB(dut, fp_width_c, fp_width_frac_c, num_samples)

    # Generate clock
    clk_period = int(1 / tb.CLOCK_FREQ_MHZ * 1e3)
    clk = Clock(dut.clk_i, period=clk_period, units='ns')
    clk_gen = cocotb.fork(clk.start())

    # Generate FIR input strobe
    strobe_num_cycles_high = 1
    strobe_num_cycles_low = tb.CLOCK_FREQ_MHZ * 1000 // tb.FS_RX_KHZ - strobe_num_cycles_high
    tb.iq_in_strobe.start(bit_toggler(repeat(strobe_num_cycles_high), repeat(strobe_num_cycles_low)))

    ###
    # Run test on DUT
    ###

    # Reset the DUT before any tests begin
    await tb.assign_defaults()
    await tb.reset()

    # Fork the 'receiving part'
    fir_out_fork = cocotb.fork(tb.read_fm_receiver_output())

    # Send input data through filter
    dut._log.info("Sending IQ samples to FM Receiver IP ...")

    for i, sample in enumerate(data_i_int):
        await RisingEdge(dut.iq_valid_i)
        dut.i_sample_i <= int(sample)
        dut.q_sample_i <= int(sample)

    await RisingEdge(dut.iq_valid_i)

    # Stop other forked routines
    fir_out_fork.kill()

    timestamp_end = time.time()
    dut._log.info("Execution took {:.2f} seconds.".format(timestamp_end - timestamp_start))

    num_received = len(tb.data_out_L)
    num_expected = len(data_o_gold_fp)

    ###
    # Plots
    ###
    if EnablePlots:
        dut._log.info("Plots ...")

        fig = plt.figure()
        plt.plot(np.arange(0, num_expected) / fs_rx_c,
                 from_fixed_point(data_o_gold_fp), "b", label="data_o_gold_fp")
        plt.plot(np.arange(0, num_received) / fs_rx_c,
                 tb.data_out_L, "r", label="data_out_L")
        plt.title("Carrier phase recovery")
        plt.grid(True)
        plt.legend()
        fig.tight_layout()
        plt.xlim([0, num_samples / fs_rx_c])
        plt.show()

    ###
    # Compare results
    ###

    # Sanity check
    if num_received < num_expected:
        # raise cocotb.result.TestError(
        dut._log.warning(
            "Did not capture enough output values: {} actual, {} expected.".format(num_received, num_expected))

    # Skip first N samples
    skip_N = 10
    dut._log.info("Skipping first N={} samples. (in:out = {}:{})".format(
        skip_N, num_expected, num_received))
    data_o_gold_fp = data_o_gold_fp[skip_N:]
    tb.data_out_L = tb.data_out_L[skip_N:]
    dut._log.info("Skipped first N={} samples.  (in:out = {}:{})".format(
        skip_N, num_expected, num_received))

    max_diff = 2**-5
    for i, res in enumerate(tb.data_out_L):
        diff = data_o_gold_fp[i] - res
        if abs(from_fixed_point(diff)) > max_diff:
            raise cocotb.result.TestError("FIR output [{}] is not matching the expected values: {}>{}.".format(
                i, abs(from_fixed_point(diff)), max_diff))
            # dut._log.info("FIR output [{}] is not matching the expected values: {}>{}.".format(
            #    i, abs(from_fixed_point(diff)), max_diff))

    norm_res = np.linalg.norm(np.array(from_fixed_point(
        data_o_gold_fp[0:num_received])) - np.array(tb.data_out_L), 2)
    dut._log.info("2-Norm = {}".format(norm_res))

    dut._log.info("Done.")
