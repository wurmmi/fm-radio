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
from helpers import *

from fm_tb import FM_TB


@cocotb.test()
async def data_processing_test(dut):
    """
    Load test data from files and send them through the DUT.
    Compare input and output afterwards.
    """

    # --------------------------------------------------------------------------
    # Constants
    # --------------------------------------------------------------------------

    # Number of seconds to process
    n_sec = 0.0005

    # Fixed point settings
    fp_width_c = 32
    fp_width_frac_c = 31

    # --------------------------------------------------------------------------
    # Prepare environment
    # --------------------------------------------------------------------------

    timestamp_start = time.time()

    tb = FM_TB(dut, n_sec, fp_width_c, fp_width_frac_c)

    # Generate clock
    clk_period = int(1 / tb.CLOCK_FREQ_MHZ * 1e3)
    clk = Clock(dut.clk_i, period=clk_period, units='ns')
    clk_gen = cocotb.fork(clk.start())

    # Generate IQ input strobe
    strobe_num_cycles_high = 1
    strobe_num_cycles_low = tb.CLOCK_FREQ_MHZ * 1000 // tb.model.FS_KHZ - strobe_num_cycles_high
    tb.iq_in_strobe.start(bit_toggler(repeat(strobe_num_cycles_high), repeat(strobe_num_cycles_low)))

    # --------------------------------------------------------------------------
    # Load data from files
    # --------------------------------------------------------------------------

    filename = "../../../sim/matlab/verification_data/rx_fm_bb.txt"
    data_fp = loadDataFromFile(filename, tb.model.num_samples_fs_c * 2, fp_width_c, fp_width_frac_c)

    # Split interleaved I/Q samples (take every other)
    data_in_i_fp = data_fp[0::2]  # start:end:step
    data_in_q_fp = data_fp[1::2]  # start:end:step

    # --------------------------------------------------------------------------
    # Run test on DUT
    # --------------------------------------------------------------------------

    # Reset the DUT before any tests begin
    await tb.assign_defaults()
    await tb.reset()

    # Fork the 'receiving parts'
    fm_demod_output_fork = cocotb.fork(tb.read_fm_demod_output())
    audio_mono_output_fork = cocotb.fork(tb.read_audio_mono_output())
    pilot_output_fork = cocotb.fork(tb.read_pilot_output())
    carrier_38k_output_fork = cocotb.fork(tb.read_carrier_38k_output())
    audio_lrdiff_output_fork = cocotb.fork(tb.read_audio_lrdiff_output())
    #audio_LR_output_fork = cocotb.fork(tb.read_audio_LR_output())

    # Send input data through filter
    dut._log.info("Sending IQ samples to FM Receiver IP ...")

    for i in range(0, len(data_in_i_fp)):
        await RisingEdge(dut.iq_valid_i)
        dut.i_sample_i <= int(fixed_to_int(data_in_i_fp[i]))
        dut.q_sample_i <= int(fixed_to_int(data_in_q_fp[i]))

    await RisingEdge(dut.channel_decoder_inst.audio_lrdiff_valid)

    # Stop other forked routines
    fm_demod_output_fork.join()
    audio_mono_output_fork.join()
    pilot_output_fork.join()
    carrier_38k_output_fork.join()
    audio_lrdiff_output_fork.join()
    # audio_LR_output_fork.join()

    # Measure time
    timestamp_end = time.time()
    dut._log.info("Execution took {:.2f} seconds.".format(timestamp_end - timestamp_start))

    # --------------------------------------------------------------------------
    # Compare results
    # --------------------------------------------------------------------------
    dut._log.info("Comparing data ...")
    tb.compareData()

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------
    # NOTE: Only showing plots, if results are NOT okay.
    dut._log.info("Plots ...")
    tb.generatePlots()

    dut._log.info("Done.")
