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

    # Variables
    data_out_L = []
    data_out_R = []
    data_out_audio_mono = []
    data_out_carrier_38k = []
    data_out_pilot = []
    data_out_fm_demod = []

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject,
                 fp_width, fp_width_frac,
                 num_samples, num_samples_fs):
        self.dut = dut
        self.dut._log.debug("Building/Connecting Testbench")

        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac
        self.num_samples_c = num_samples
        self.num_samples_fs_c = num_samples_fs

        self.fm_receiver_model = FM_RECEIVER_MODEL()

        self.iq_in_strobe = BitDriver(self.dut.iq_valid_i, self.dut.clk_i)

    @cocotb.coroutine
    async def reset(self):
        self.dut._log.info("Resetting DUT ...")

        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)
        self.dut.rst_i <= 1
        await Timer(3.3, units='us')
        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)

    @cocotb.coroutine
    async def assign_defaults(self):
        self.dut._log.info("Setting input port defaults ...")

        self.dut.iq_valid_i <= 0
        self.dut.i_sample_i <= 0
        self.dut.q_sample_i <= 0

    @cocotb.coroutine
    async def read_fm_demod_output(self):
        edge = RisingEdge(self.dut.fm_demod_valid)
        while(True):
            await edge
            fm_demod = self.dut.fm_demod.value.signed_integer
            self.data_out_fm_demod.append(
                int_to_fixed(fm_demod, self.fp_width_c, self.fp_width_frac_c))

            # print every 100th number to show progress
            size = len(self.data_out_fm_demod)
            if size % 100 == 0:
                self.dut._log.info("Progress fm_demod: {}".format(size))

            if size >= self.num_samples_fs_c:
                break

    @cocotb.coroutine
    async def read_audio_mono_output(self):
        edge = RisingEdge(self.dut.channel_decoder_inst.audio_mono_valid)
        while(True):
            await edge
            audio_mono = self.dut.channel_decoder_inst.audio_mono.value.signed_integer
            self.data_out_audio_mono.append(
                int_to_fixed(audio_mono, self.fp_width_c, self.fp_width_frac_c))

            # print every 100th number to show progress
            size = len(self.data_out_audio_mono)
            if size % 100 == 0:
                self.dut._log.info("Progress audio_mono: {}".format(size))

            if size >= self.num_samples_c:
                break

    @cocotb.coroutine
    async def read_pilot_output(self):
        edge = RisingEdge(self.dut.channel_decoder_inst.recover_carriers_inst.pilot_valid)
        while(True):
            await edge
            pilot = self.dut.channel_decoder_inst.recover_carriers_inst.pilot.value.signed_integer
            self.data_out_pilot.append(
                int_to_fixed(pilot, self.fp_width_c, self.fp_width_frac_c))

            # print every 100th number to show progress
            size = len(self.data_out_pilot)
            if size % 100 == 0:
                self.dut._log.info("Progress pilot: {}".format(size))

            if size >= self.num_samples_c:
                break

    @cocotb.coroutine
    async def read_carrier_38k_output(self):
        edge = RisingEdge(self.dut.channel_decoder_inst.recover_carriers_inst.carrier_38k_valid)
        while(True):
            await edge
            carrier_38k = self.dut.channel_decoder_inst.recover_carriers_inst.carrier_38k.value.signed_integer
            self.data_out_carrier_38k.append(
                int_to_fixed(carrier_38k, self.fp_width_c, self.fp_width_frac_c))

            # print every 100th number to show progress
            size = len(self.data_out_carrier_38k)
            if size % 100 == 0:
                self.dut._log.info("Progress carrier_38k: {}".format(size))

            if size >= self.num_samples_c:
                break

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

            # print every 100th number to show progress
            size = len(self.data_out_L)
            if size % 100 == 0:
                self.dut._log.info("Progress audio_LR: {}".format(size))

            if size >= self.num_samples_c:
                break
