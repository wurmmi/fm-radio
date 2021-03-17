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
    EnablePlots = True

    timestamp_start = time.time()

    # --------------------------------------------------------------------------
    # Constants
    # --------------------------------------------------------------------------

    # Number of seconds to process
    n_sec = 0.002

    # Sample rate (set according to Matlab model!)
    fs_rx_khz_c = 120
    fs_khz_c = 960

    # Fixed point settings
    fp_width_c = 32
    fp_width_frac_c = 31

    # Derived constants
    fs_c = fs_khz_c * 1000
    fs_rx_c = fs_rx_khz_c * 1000
    num_samples_fs = int(n_sec * fs_khz_c * 1000)
    num_samples = int(n_sec * fs_rx_khz_c * 1000)

    dut._log.info("num_samples_fs: {}, num_samples: {} ".format(num_samples_fs, num_samples))

    # --------------------------------------------------------------------------
    # Load data from files
    # --------------------------------------------------------------------------

    filename = "../../../sim/matlab/verification_data/rx_fm_bb.txt"
    data_fp = loadDataFromFile(filename, num_samples_fs * 2, fp_width_c, fp_width_frac_c)

    # Split interleaved I/Q samples (take every other)
    data_in_i_fp = data_fp[0::2]  # start:end:step
    data_in_q_fp = data_fp[1::2]  # start:end:step

    filename = "../../../sim/matlab/verification_data/rx_fm_demod.txt"
    fm_demod_gold_fp = loadDataFromFile(filename, num_samples_fs, fp_width_c, fp_width_frac_c)

    filename = "../../../sim/matlab/verification_data/rx_audio_mono.txt"
    audio_mono_gold_fp = loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)

    filename = "../../../sim/matlab/verification_data/rx_pilot.txt"
    pilot_gold_fp = loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)

    filename = "../../../sim/matlab/verification_data/rx_carrier38kHz.txt"
    carrier_38k_gold_fp = loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)

    # --------------------------------------------------------------------------
    # Prepare environment
    # --------------------------------------------------------------------------

    tb = FM_TB(dut, fp_width_c, fp_width_frac_c, num_samples, num_samples_fs)

    assert (tb.CLOCK_FREQ_MHZ * 1e3 / fs_rx_khz_c).is_integer(), \
        "Clock rate and fs_rx must have an integer relation!"

    # Generate clock
    clk_period = int(1 / tb.CLOCK_FREQ_MHZ * 1e3)
    clk = Clock(dut.clk_i, period=clk_period, units='ns')
    clk_gen = cocotb.fork(clk.start())

    # Generate IQ input strobe
    strobe_num_cycles_high = 1
    strobe_num_cycles_low = tb.CLOCK_FREQ_MHZ * 1000 // fs_khz_c - strobe_num_cycles_high
    tb.iq_in_strobe.start(bit_toggler(repeat(strobe_num_cycles_high), repeat(strobe_num_cycles_low)))

    # --------------------------------------------------------------------------
    # Run test on DUT
    # --------------------------------------------------------------------------

    # Reset the DUT before any tests begin
    await tb.assign_defaults()
    await tb.reset()

    # Fork the 'receiving part'
    fm_demod_output_fork = cocotb.fork(tb.read_fm_demod_output())
    audio_mono_output_fork = cocotb.fork(tb.read_audio_mono_output())
    pilot_output_fork = cocotb.fork(tb.read_pilot_output())
    carrier_38k_output_fork = cocotb.fork(tb.read_carrier_38k_output())
    #audio_LR_output_fork = cocotb.fork(tb.read_audio_LR_output())

    # Send input data through filter
    dut._log.info("Sending IQ samples to FM Receiver IP ...")

    for i in range(0, len(data_in_i_fp)):
        await RisingEdge(dut.iq_valid_i)
        dut.i_sample_i <= int(fixed_to_int(data_in_i_fp[i]))
        dut.q_sample_i <= int(fixed_to_int(data_in_q_fp[i]))

    await RisingEdge(dut.channel_decoder_inst.audio_mono_valid)

    # Stop other forked routines
    fm_demod_output_fork.join()
    audio_mono_output_fork.join()
    pilot_output_fork.join()
    carrier_38k_output_fork.join()
    # audio_LR_output_fork.join()

    # Measure time
    timestamp_end = time.time()
    dut._log.info("Execution took {:.2f} seconds.".format(timestamp_end - timestamp_start))

    # --------------------------------------------------------------------------
    # Compare results
    # --------------------------------------------------------------------------

    # Compensate shift between file data and testbench data
    prepend_n_zeros(fm_demod_gold_fp, 2, fp_width_c, fp_width_frac_c)
    append_n_zeros(audio_mono_gold_fp, 2, fp_width_c, fp_width_frac_c)
    append_n_zeros(pilot_gold_fp, 3, fp_width_c, fp_width_frac_c)
    append_n_zeros(carrier_38k_gold_fp, 3, fp_width_c, fp_width_frac_c)

    # Compare
    okay_fm_demod = compareResultsOkay(dut,
                                       fm_demod_gold_fp,
                                       tb.data_out_fm_demod,
                                       fail_on_err=True,
                                       max_error_abs=2**-5,
                                       max_error_norm=0.11,
                                       skip_n_samples=30,
                                       data_name="fm_demod")

    okay_audio_mono = compareResultsOkay(dut,
                                         audio_mono_gold_fp,
                                         tb.data_out_audio_mono,
                                         fail_on_err=True,
                                         max_error_abs=2**-5,
                                         max_error_norm=0.06,
                                         skip_n_samples=10,
                                         data_name="audio_mono")

    okay_pilot = compareResultsOkay(dut,
                                    pilot_gold_fp,
                                    tb.data_out_pilot,
                                    fail_on_err=False,
                                    max_error_abs=2**-5,
                                    max_error_norm=0.06,
                                    skip_n_samples=10,
                                    data_name="pilot")

    okay_carrier_38k = compareResultsOkay(dut,
                                          carrier_38k_gold_fp,
                                          tb.data_out_carrier_38k,
                                          fail_on_err=False,
                                          max_error_abs=2**-5,
                                          max_error_norm=0.06,
                                          skip_n_samples=10,
                                          data_name="carrier_38k")

    # TODO: Bypassing for now
    #okay_fm_demod = False
    #okay_audio_mono = False
    #okay_pilot = False

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------
    # NOTE: Only showing plots, if results are NOT okay.

    if EnablePlots:
        dut._log.info("Plots ...")
        data = (
            (np.arange(0, num_samples_fs) / fs_c,
                from_fixed_point(fm_demod_gold_fp), "fm_demod_gold_fp"),
            (np.arange(0, num_samples_fs) / fs_c,
                tb.data_out_fm_demod, "tb.data_out_fm_demod")
        )
        plotData(data, title="FM Demodulator",
                 filename="sim_build/plot_fm_demod.png",
                 show=(not okay_fm_demod), block=False)

        data = (
            (np.arange(0, num_samples) / fs_rx_c,
                from_fixed_point(audio_mono_gold_fp), "audio_mono_gold_fp"),
            (np.arange(0, num_samples) / fs_rx_c,
                tb.data_out_audio_mono, "tb.data_out_audio_mono")
        )
        plotData(data, title="Audio Mono",
                 filename="sim_build/plot_audio_mono.png",
                 show=(not okay_audio_mono))

        data = (
            (np.arange(0, num_samples) / fs_rx_c,
                from_fixed_point(pilot_gold_fp), "pilot_gold_fp"),
            (np.arange(0, num_samples) / fs_rx_c,
                tb.data_out_pilot, "tb.data_out_pilot")
        )
        plotData(data, title="Pilot",
                 filename="sim_build/plot_pilot.png",
                 show=(not okay_pilot))

        data = (
            (np.arange(0, num_samples) / fs_rx_c,
                from_fixed_point(carrier_38k_gold_fp), "carrier_38k_gold_fp"),
            (np.arange(0, num_samples) / fs_rx_c,
                tb.data_out_carrier_38k, "tb.data_out_carrier_38k")
        )
        plotData(data, title="carrier_38k",
                 filename="sim_build/plot_carrier_38k.png",
                 show=(not okay_carrier_38k))

    dut._log.info("Done.")
