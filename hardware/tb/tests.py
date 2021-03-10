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
from cocotb.triggers import RisingEdge, Timer
from fixed_point import *

from fm_tb import FM_TB


@cocotb.test()
async def fir_filter_test(dut):
    timestamp_start = time.time()
    """Load test data from files and send them through the DUT.
       Compare input and output afterwards."""

    ###
    # Constants
    ###
    fp_width_c = 16
    fp_width_frac_c = 15

    ###
    # Load data from files
    ###
    filename = "../../sim/matlab/verification_data/rx_fmChannelData.txt"
    data_i = []
    with open(filename) as fd:
        for line in fd:
            data_i.append(float(line.strip('\n')))

    # Convert to fixed point and back to int
    data_i_fp = to_fixed_point(data_i, fp_width_c, fp_width_frac_c)
    data_i_int = fixed_to_int(data_i_fp)

    filename = "../../sim/matlab/verification_data/rx_pilot.txt"
    data_o_gold = []
    with open(filename) as fd:
        for line in fd:
            data_o_gold.append(float(line.strip('\n')))

    # Convert to fixed point
    data_o_gold_fp = to_fixed_point(data_o_gold, fp_width_c, fp_width_frac_c)

    ###
    # Prepare environment
    ###
    tb = FM_TB(dut)

    # Generate clock
    clk = Clock(dut.clk_i, period=1 / tb.CLOCK_FREQ_MHZ * 1000, units='ns')
    clk_gen = cocotb.fork(clk.start())

    ###
    # Run test on DUT
    ###
    # Reset the DUT before any tests begin
    await tb.reset()

    await Timer(5, units='us')

    # Run input data through filter
    dut._log.info("Sending input data through filter ...")

    data_out = np.zeros(len(data_i_int))
    for i, sample in enumerate(data_i_int):
        dut.fir_i <= int(sample)
        dut.fir_valid_i <= 1

        await RisingEdge(dut.clk_i)
        dut.fir_valid_i <= 0

        await RisingEdge(dut.clk_i)

        # if duf.fir_valid_o == '1' @ TODO ?
        sample_out = dut.fir_o.value.signed_integer
        data_out[i] = int_to_fixed(sample_out, fp_width_c, fp_width_frac_c)

    timestamp_end = time.time()
    dut._log.info("Execution took: {:.2f} seconds.".format(timestamp_end - timestamp_start))

    ###
    # Plots
    ###
    dut._log.info("Plots ...")

    plt.figure()
    plt.plot(from_fixed_point(data_o_gold_fp), "b", label="data_o_gold_fp")
    plt.plot(data_out, "r", label="data_out")
    plt.title("Time domain signal")
    plt.legend()
    plt.show()

    dut._log.info("Done.")
