################################################################################
# File        : test.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testcases for the FM Receiver IP.
################################################################################


import time

import cocotb
import fm_global as fm_global
import helpers as helper
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from fixed_point import fixed_to_int

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
    n_sec = 0.001

    # --------------------------------------------------------------------------
    # Prepare environment
    # --------------------------------------------------------------------------
    timestamp_start = time.time()

    tb = FM_TB(dut, n_sec)

    # Generate clock
    clk_period_ns = round(1 / tb.CLOCK_FREQ_MHZ * 1e3)
    clk = Clock(dut.clk_i, period=clk_period_ns, units='ns')
    clk_gen = cocotb.fork(clk.start())

    # --------------------------------------------------------------------------
    # Load data from files
    # --------------------------------------------------------------------------
    dut._log.info("Loading input data ...")

    filename = "../../../../sim/matlab/verification_data/rx_fm_bb.txt"
    data_fp = helper.loadDataFromFile(filename, tb.model.num_samples_fs_c * 2,
                                      fm_global.fp_width_c, fm_global.fp_width_frac_c)

    # Get interleaved I/Q samples (take every other)
    data_in_i_fp = data_fp[0::2]  # start:end:step
    data_in_q_fp = data_fp[1::2]  # start:end:step

    # Combine IQ samples
    data_in_iq = []
    for i in range(0, len(data_in_i_fp)):
        in_i = int(fixed_to_int(data_in_i_fp[i]))
        in_q = int(fixed_to_int(data_in_q_fp[i]))
        value = (in_q << 16) + in_i
        data_in_iq.append(value)

    # --------------------------------------------------------------------------
    # Run test on DUT
    # --------------------------------------------------------------------------

    # Reset the DUT before any tests begin
    await tb.assign_defaults()
    await tb.reset()

    # Fork the 'receiving parts'
    fm_demod_output_fork = cocotb.fork(tb.read_fm_demod_output())
    fm_channel_data_output_fork = cocotb.fork(tb.read_fm_channel_data_output())
    audio_mono_output_fork = cocotb.fork(tb.read_audio_mono_output())
    pilot_output_fork = cocotb.fork(tb.read_pilot_output())
    carrier_38k_output_fork = cocotb.fork(tb.read_carrier_38k_output())
    audio_lrdiff_output_fork = cocotb.fork(tb.read_audio_lrdiff_output())
    audio_L_output_fork = cocotb.fork(tb.read_audio_L_output())
    audio_R_output_fork = cocotb.fork(tb.read_audio_R_output())

    # Send input data through filter
    dut._log.info("Sending IQ samples to FM Receiver IP ...")

    for i in range(0, len(data_in_iq)):
        await tb.axis_m.write(data_in_iq[i])

    await RisingEdge(dut.fm_receiver_inst.channel_decoder_inst.audio_lrdiff_valid)

    # Await forked routines to stop
    await fm_demod_output_fork
    await fm_channel_data_output_fork
    await audio_mono_output_fork
    await pilot_output_fork
    await carrier_38k_output_fork
    await audio_lrdiff_output_fork
    await audio_L_output_fork
    await audio_R_output_fork

    # Measure time
    duration_s = int(time.time() - timestamp_start)
    mins, secs = divmod(duration_s, 60)
    dut._log.info("Execution took {:02d}:{:02d} minutes.".format(mins, secs))

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
