################################################################################
# File        : test.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testcases for the FM Receiver IP.
################################################################################


import time

import cocotb
import fm_global
import helpers as helper
from cocotb.clock import Clock
from cocotb.generators import repeat
from cocotb.generators.bit import bit_toggler
from fixed_point import fixed_to_int

from fm_tb import FM_TB


@cocotb.test()
async def axi_lite_memory_map_test(dut):
    """
    Read and write AXI-lite registers of the DUT.
    """

    # --------------------------------------------------------------------------
    # Prepare environment
    # --------------------------------------------------------------------------

    timestamp_start = time.time()

    tb = FM_TB(dut, 0)

    # Generate clock
    clk_period_ns = round(1 / tb.CLOCK_FREQ_MHZ * 1e3)
    clk = Clock(dut.clk_i, period=clk_period_ns, units='ns')
    clk_gen = cocotb.fork(clk.start())

    # --------------------------------------------------------------------------
    # Run test on DUT
    # --------------------------------------------------------------------------

    # Reset the DUT before any tests begin
    await tb.assign_defaults()
    await tb.reset()

    # Read all registers
    for reg_nr in range(3):
        word_addr = reg_nr * 4
        dut._log.info(f"##### Read register address: {word_addr} ...")
        rddata = await tb.axil_mm_m.read(word_addr, 4)
        dut._log.info(f"rddata: {rddata.data}")

    # Write some registers
    # Reg: LED_CONTROL (TODO: generate this with Register Engine)
    word_addr = 4
    await tb.axil_mm_m.write(word_addr, b'\xff')
    rddata = await tb.axil_mm_m.read(word_addr, 4)
    rddata_expected = bytearray.fromhex("07000000")  # little endian and register only implements 3 bit in HW
    assert rddata.data == rddata_expected

    await tb.axil_mm_m.write(word_addr, b'\x00')
    rddata = await tb.axil_mm_m.read(word_addr, 4)
    rddata_expected = bytearray.fromhex("00000000")
    assert rddata.data == rddata_expected

    # Measure time
    duration_s = int(time.time() - timestamp_start)
    mins, secs = divmod(duration_s, 60)
    dut._log.info("Execution took {:02d}:{:02d} minutes.".format(mins, secs))


@ cocotb.test()
async def axi_stream_dsp_test(dut):
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

    filename = "../../../../../sim/matlab/verification_data/rx_fm_bb.txt"
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

    # Generate backpressure signal (AXI stream tready) for IPs' stream output
    # NOTE:
    #  This is not generating the actual ~40 kHz output frequency (as defined by fm_global.fs_audio_c).
    #  It generates a much faster output, to speed up the testbench (see "output_speedup_factor").
    # NOTE:
    #  This speedup factor needs to be chosen carefully. The IP needs to complete the calculation for one sample,
    #  before the next sample can be taken from the input. Therefore, set the factor small, to ensure enough
    #  low-cycles, to allow the IP to complete one entire calculation.
    output_speedup_factor = 50
    strobe_num_cycles_high = 1
    strobe_num_cycles_low = tb.CLOCK_FREQ_MHZ * 1e6 // fm_global.fs_audio_c // output_speedup_factor - strobe_num_cycles_high
    ratio = strobe_num_cycles_low // strobe_num_cycles_high
    tb.backpressure_i2s.start(bit_toggler(repeat(strobe_num_cycles_high), repeat(strobe_num_cycles_low)))
    assert ratio >= 9, "output_speedup_factor is set too high! --> IP won't have enough time to calculate a sample, before the next one arrives"

    # Fork the 'receiving parts'
    fm_demod_output_fork = cocotb.fork(tb.read_fm_demod_output())
    fm_channel_data_output_fork = cocotb.fork(tb.read_fm_channel_data_output())
    audio_mono_output_fork = cocotb.fork(tb.read_audio_mono_output())
    pilot_output_fork = cocotb.fork(tb.read_pilot_output())
    carrier_38k_output_fork = cocotb.fork(tb.read_carrier_38k_output())
    audio_lrdiff_output_fork = cocotb.fork(tb.read_audio_lrdiff_output())
    audio_L_output_fork = cocotb.fork(tb.read_audio_L_output())
    audio_R_output_fork = cocotb.fork(tb.read_audio_R_output())
    audio_output_fork = cocotb.fork(tb.read_audio_output())

    # Send input data to IP
    dut._log.info("Sending IQ samples to FM Receiver IP ...")

    for i, value in enumerate(data_in_iq):
        await tb.axis_m.write(value)

    dut._log.info("Waiting to receive enough samples ...")
    # Await forked routines to stop.
    # They stop, when the expected number of samples were read.
    await fm_demod_output_fork
    await fm_channel_data_output_fork
    await audio_mono_output_fork
    await pilot_output_fork
    await carrier_38k_output_fork
    await audio_lrdiff_output_fork
    await audio_L_output_fork
    await audio_R_output_fork
    await audio_output_fork

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
