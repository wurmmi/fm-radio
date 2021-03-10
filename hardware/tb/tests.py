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
    num_samples = 150
    fs_rx_c = 120e3  # set according to files in folder verification_data/

    fp_width_c = 32
    fp_width_frac_c = 31

    ###
    # Load data from files
    ###
    filename = "../../sim/matlab/verification_data/rx_fmChannelData.txt"
    data_i = []
    with open(filename) as fd:
        val_count = 0
        for line in fd:
            data_i.append(float(line.strip('\n')))
            val_count += 1
            # Stop after required number of samples
            if val_count > num_samples:
                break

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

    # Generate clocks
    clk_period = int(1 / tb.CLOCK_FREQ_MHZ * 1e3)
    clk = Clock(dut.clk_i, period=clk_period, units='ns')
    clk_gen = cocotb.fork(clk.start())

    clk_period_fs = int(1 / tb.FS_RX_KHZ * 1e6)
    clk_fs = Clock(dut.fir_valid_i, period=clk_period_fs, units='ns')
    clk_gen_fs = cocotb.fork(clk_fs.start(start_high=False))

    ###
    # Run test on DUT
    ###

    # Reset the DUT before any tests begin
    await tb.reset()
    await tb.assign_defaults()

    # Run input data through filter
    dut._log.info("Sending input data through filter ...")

    data_out = np.zeros(len(data_i_int))
    for i, sample in enumerate(data_i_int):
        dut.fir_i <= int(sample)

        await RisingEdge(dut.fir_valid_i)
        dut.fir_valid_i <= 0

        await RisingEdge(dut.fir_valid_o)

        sample_out = dut.fir_o.value.signed_integer * 11
        data_out[i] = int_to_fixed(sample_out, fp_width_c, fp_width_frac_c)
        print(i)

    timestamp_end = time.time()
    dut._log.info("Execution took {:.2f} seconds.".format(timestamp_end - timestamp_start))

    ###
    # Plots
    ###
    dut._log.info("Plots ...")

    fig = plt.figure()
    plt.plot(np.arange(0, len(data_o_gold_fp)) / fs_rx_c,
             from_fixed_point(data_o_gold_fp), "b", label="data_o_gold_fp")
    plt.plot(np.arange(0, len(data_out)) / fs_rx_c,
             data_out, "r", label="data_out")
    plt.title("Carrier phase recovery")
    plt.grid(True)
    plt.legend()
    fig.tight_layout()
    plt.xlim([0, 0.002])
    plt.show()

    dut._log.info("Done.")
