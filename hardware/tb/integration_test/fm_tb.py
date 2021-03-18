################################################################################
# File        : fm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench environment
################################################################################

import cocotb
from cocotb.drivers import BitDriver
from cocotb.triggers import RisingEdge, Timer
from fixed_point import *
from helpers import *
from vhdl_sampler import VHDL_SAMPLER

from fm_receiver_model import FM_RECEIVER_MODEL


class FM_TB(object):
    # Constants
    CLOCK_FREQ_MHZ = 48
    EnableFailOnError = False
    EnablePlots = True

    # Variables
    data_out_fm_demod = []
    data_out_audio_mono = []
    data_out_pilot = []
    data_out_carrier_38k = []
    data_out_audio_lrdiff = []
    data_out_audio_L = []
    data_out_audio_R = []

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject,
                 n_sec, fp_width, fp_width_frac):
        self.dut = dut
        self.n_sec = n_sec
        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac

        self.model = FM_RECEIVER_MODEL(n_sec, fp_width, fp_width_frac)

        # Derived constants
        self.fs_c = self.model.FS_KHZ * 1000
        self.fs_rx_c = self.model.FS_RX_KHZ * 1000

        assert (self.CLOCK_FREQ_MHZ * 1e3 / self.model.FS_RX_KHZ).is_integer(), \
            "Clock rate and fs_rx must have an integer relation!"

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
        sampler = VHDL_SAMPLER("fm_demod", self.dut,
                               self.dut.fm_demod,
                               self.dut.fm_demod_valid,
                               self.model.num_samples_fs_c,
                               self.fp_width_c, self.fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_fm_demod)

    @cocotb.coroutine
    async def read_audio_mono_output(self):
        sampler = VHDL_SAMPLER("audio_mono", self.dut,
                               self.dut.channel_decoder_inst.audio_mono,
                               self.dut.channel_decoder_inst.audio_mono_valid,
                               self.model.num_samples_c,
                               self.fp_width_c, self.fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_audio_mono)

    @cocotb.coroutine
    async def read_pilot_output(self):
        sampler = VHDL_SAMPLER("pilot", self.dut,
                               self.dut.channel_decoder_inst.recover_carriers_inst.pilot,
                               self.dut.channel_decoder_inst.recover_carriers_inst.pilot_valid,
                               self.model.num_samples_c,
                               self.fp_width_c, self.fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_pilot)

    @cocotb.coroutine
    async def read_carrier_38k_output(self):
        sampler = VHDL_SAMPLER("carrier_38k", self.dut,
                               self.dut.channel_decoder_inst.recover_carriers_inst.carrier_38k,
                               self.dut.channel_decoder_inst.recover_carriers_inst.carrier_38k_valid,
                               self.model.num_samples_c,
                               self.fp_width_c, self.fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_carrier_38k)

    @cocotb.coroutine
    async def read_audio_lrdiff_output(self):
        sampler = VHDL_SAMPLER("audio_lrdiff", self.dut,
                               self.dut.channel_decoder_inst.audio_lrdiff,
                               self.dut.channel_decoder_inst.audio_lrdiff_valid,
                               self.model.num_samples_c,
                               self.fp_width_c, self.fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_audio_lrdiff)

    @cocotb.coroutine
    async def read_audio_L_output(self):
        sampler_L = VHDL_SAMPLER("audio_L", self.dut,
                                 self.dut.audio_L_o,
                                 self.dut.audio_valid_o,
                                 self.model.num_samples_c,
                                 self.fp_width_c, self.fp_width_frac_c)

        await sampler_L.read_vhdl_output(self.data_out_audio_L)

    @cocotb.coroutine
    async def read_audio_R_output(self):
        sampler_R = VHDL_SAMPLER("audio_R", self.dut,
                                 self.dut.audio_R_o,
                                 self.dut.audio_valid_o,
                                 self.model.num_samples_c,
                                 self.fp_width_c, self.fp_width_frac_c)

        await sampler_R.read_vhdl_output(self.data_out_audio_R)

    def compareData(self):
        # Shift loaded file-data to compensate shift to testbench-data
        move_n_right(self.model.gold_fm_demod_fp, 2, self.fp_width_c, self.fp_width_frac_c)
        move_n_left(self.model.gold_audio_mono_fp, 1, self.fp_width_c, self.fp_width_frac_c)
        move_n_left(self.model.gold_pilot_fp, 1, self.fp_width_c, self.fp_width_frac_c)
        move_n_left(self.model.gold_carrier_38k_fp, 1, self.fp_width_c, self.fp_width_frac_c)
        move_n_left(self.model.gold_audio_lrdiff_fp, 1, self.fp_width_c, self.fp_width_frac_c)
        move_n_left(self.model.gold_audio_L_fp, 1, self.fp_width_c, self.fp_width_frac_c)
        move_n_left(self.model.gold_audio_R_fp, 1, self.fp_width_c, self.fp_width_frac_c)

        # Compare
        self.ok_fm_demod = compareResultsOkay(self.model.gold_fm_demod_fp,
                                              self.data_out_fm_demod,
                                              fail_on_err=self.EnableFailOnError,
                                              max_error_abs=2**-5,
                                              max_error_norm=0.05,
                                              skip_n_samples=30,
                                              data_name="fm_demod")

        self.ok_audio_mono = compareResultsOkay(self.model.gold_audio_mono_fp,
                                                self.data_out_audio_mono,
                                                fail_on_err=self.EnableFailOnError,
                                                max_error_abs=2**-5,
                                                max_error_norm=0.05,
                                                skip_n_samples=10,
                                                data_name="audio_mono")

        self.ok_pilot = compareResultsOkay(self.model.gold_pilot_fp,
                                           self.data_out_pilot,
                                           fail_on_err=self.EnableFailOnError,
                                           max_error_abs=2**-5,
                                           max_error_norm=0.06,
                                           skip_n_samples=10,
                                           data_name="pilot")

        self.ok_carrier_38k = compareResultsOkay(self.model.gold_carrier_38k_fp,
                                                 self.data_out_carrier_38k,
                                                 fail_on_err=self.EnableFailOnError,
                                                 max_error_abs=2**-5,
                                                 max_error_norm=0.06,
                                                 skip_n_samples=10,
                                                 data_name="carrier_38k")

        self.ok_audio_lrdiff = compareResultsOkay(self.model.gold_audio_lrdiff_fp,
                                                  self.data_out_audio_lrdiff,
                                                  fail_on_err=self.EnableFailOnError,
                                                  max_error_abs=2**-5,
                                                  max_error_norm=0.06,
                                                  skip_n_samples=10,
                                                  data_name="audio_lrdiff")

        self.ok_audio_L = compareResultsOkay(self.model.gold_audio_L_fp,
                                             self.data_out_audio_L,
                                             fail_on_err=self.EnableFailOnError,
                                             max_error_abs=2**-5,
                                             max_error_norm=0.06,
                                             skip_n_samples=10,
                                             data_name="audio_L")

        self.ok_audio_R = compareResultsOkay(self.model.gold_audio_R_fp,
                                             self.data_out_audio_R,
                                             fail_on_err=self.EnableFailOnError,
                                             max_error_abs=2**-5,
                                             max_error_norm=0.06,
                                             skip_n_samples=10,
                                             data_name="audio_R")

    def generatePlots(self):
        if not self.EnablePlots:
            return

        # TODO: Enable plots for debug
        #self.ok_fm_demod = False
        #self.ok_audio_mono = False
        #self.ok_pilot = False
        #self.ok_carrier_38k = False
        #self.ok_audio_lrdiff = False
        #self.ok_audio_L = False
        #self.ok_audio_R = False

        # -----------------------------------------------------------------
        tn = np.arange(0, self.model.num_samples_fs_c) / self.fs_c
        data = (
            (tn, from_fixed_point(self.model.gold_fm_demod_fp), "gold_fm_demod_fp"),
            (tn, self.data_out_fm_demod, "data_out_fm_demod")
        )
        plotData(data, title="FM Demodulator",
                 filename="sim_build/plot_fm_demod.png",
                 show=(not self.ok_fm_demod))

        # -----------------------------------------------------------------
        tn = np.arange(0, self.model.num_samples_c) / self.fs_rx_c
        data = (
            (tn, from_fixed_point(self.model.gold_audio_mono_fp), "gold_audio_mono_fp"),
            (tn, self.data_out_audio_mono, "data_out_audio_mono")
        )
        plotData(data, title="Audio Mono",
                 filename="sim_build/plot_audio_mono.png",
                 show=(not self.ok_audio_mono))

        # -----------------------------------------------------------------
        data = (
            (tn, from_fixed_point(self.model.gold_pilot_fp), "gold_pilot_fp"),
            (tn, self.data_out_pilot, "data_out_pilot")
        )
        plotData(data, title="Pilot",
                 filename="sim_build/plot_pilot.png",
                 show=(not self.ok_pilot))

        # -----------------------------------------------------------------
        data = (
            (tn, from_fixed_point(self.model.gold_carrier_38k_fp), "gold_carrier_38k_fp"),
            (tn, self.data_out_carrier_38k, "data_out_carrier_38k")
        )
        plotData(data, title="Carrier 38kHz",
                 filename="sim_build/plot_carrier_38k.png",
                 show=(not self.ok_carrier_38k))

        # -----------------------------------------------------------------
        data = (
            (tn, from_fixed_point(self.model.gold_audio_lrdiff_fp), "gold_audio_lrdiff_fp"),
            (tn, self.data_out_audio_lrdiff, "data_out_audio_lrdiff")
        )
        plotData(data, title="Audio LR Diff",
                 filename="sim_build/plot_audio_lrdiff.png",
                 show=(not self.ok_audio_lrdiff))

        # -----------------------------------------------------------------
        data = (
            (tn, from_fixed_point(self.model.gold_audio_L_fp), "gold_audio_L_fp"),
            (tn, self.data_out_audio_L, "data_out_audio_L")
        )
        plotData(data, title="Audio L",
                 filename="sim_build/plot_audio_L.png",
                 show=(not self.ok_audio_L))

        # -----------------------------------------------------------------
        data = (
            (tn, from_fixed_point(self.model.gold_audio_R_fp), "gold_audio_R_fp"),
            (tn, self.data_out_audio_R, "data_out_audio_R")
        )
        plotData(data, title="Audio R",
                 filename="sim_build/plot_audio_R.png",
                 show=(not self.ok_audio_R))
