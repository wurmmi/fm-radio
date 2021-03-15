################################################################################
# File        : fm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench and Model of the gain ip
################################################################################

import cocotb
from cocotb.drivers import BitDriver
from cocotb.triggers import RisingEdge, Timer
from fixed_point import *

from fm_receiver_model import FM_RECEIVER_MODEL


class FM_TB(object):
    # Constants
    CLOCK_FREQ_MHZ = 48
    FS_RX_KHZ = 120
    FS_KHZ = 960

    # Variables
    data_out_L = []
    data_out_R = []
    data_out_audio_mono = []
    data_out_fm_demod = []

    assert (CLOCK_FREQ_MHZ * 1e3 / FS_RX_KHZ).is_integer(), \
        "Clock rate and fs_rx must have an integer relation!"

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject, fp_width, fp_width_frac, num_samples):
        self.dut = dut
        self.dut._log.debug("Building/Connecting Testbench")

        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac
        self.num_samples_c = num_samples

        self.fm_receiver_model = FM_RECEIVER_MODEL()

        self.iq_in_strobe = BitDriver(self.dut.iq_valid_i, self.dut.clk_i)

    @cocotb.coroutine
    async def reset(self):
        self.dut._log.info("Resetting DUT ...")

        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)
        self.dut.rst_i <= 1
        await Timer(3.3, units="us")
        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)

    @cocotb.coroutine
    async def assign_defaults(self):
        self.dut._log.info("Setting input port defaults ...")

        self.dut.iq_valid_i <= 0
        self.dut.i_sample_i <= 0
        self.dut.q_sample_i <= 0

    @cocotb.coroutine
    async def read_audio_LR_output(self):
        edge = RisingEdge(self.dut.audio_valid_o)
        while(True):
            await edge
            audio_L = self.dut.audio_L_o.value.signed_integer
            audio_R = self.dut.audio_L_o.value.signed_integer
            self.data_out_L.append(
                int_to_fixed(audio_L, self.fp_width_c, self.fp_width_frac_c))
            self.data_out_R.append(
                int_to_fixed(audio_R, self.fp_width_c, self.fp_width_frac_c))

            # print every 10th number to show progress
            size = len(self.data_out_L)
            if size % 10 == 0:
                self.dut._log.info("Progress audio_LR: {}".format(size))

    @cocotb.coroutine
    async def read_fm_demod_output(self):
        edge = RisingEdge(self.dut.fm_demod_valid)
        while(True):
            await edge
            fm_demod = self.dut.fm_demod.value.signed_integer
            self.data_out_fm_demod.append(
                int_to_fixed(fm_demod, self.fp_width_c, self.fp_width_frac_c))

            # print every 10th number to show progress
            size = len(self.data_out_fm_demod)
            if size % 10 == 0:
                self.dut._log.info("Progress fm_demod: {}".format(size))
