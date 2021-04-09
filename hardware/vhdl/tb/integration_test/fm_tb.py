################################################################################
# File        : fm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench environment
################################################################################

import cocotb
from cocotb.drivers import BitDriver
from cocotb.triggers import RisingEdge, Timer
from cocotbext.axi4stream.drivers import Axi4StreamMaster
from fixed_point import *
from fm_global import *
from fm_receiver_model import FM_RECEIVER_MODEL
from helpers import *
from tb_analyzer_helper import TB_ANALYZER_HELPER
from tb_data_result_loader import TB_DATA_RESULT_LOADER
from vhdl_sampler import VHDL_SAMPLER


class FM_TB(object):
    # Constants
    CLOCK_FREQ_MHZ = 48
    EnableFailOnError = False
    EnablePlots = True

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject,
                 n_sec):
        self.dut = dut
        self.n_sec = n_sec

        golden_data_directory = "../../../../sim/matlab/verification_data/"
        self.model = FM_RECEIVER_MODEL(n_sec, golden_data_directory)

        slave_interface_to_connect_to = "s0_axis"
        self.axis_m = Axi4StreamMaster(dut, slave_interface_to_connect_to, dut.clk_i)

        # Derived constants
        assert (self.CLOCK_FREQ_MHZ * 1e9 / fs_rx_c).is_integer(), \
            "Clock rate and fs_rx_c must have an integer relation!"

        # Variables
        self.tb_result_loader = TB_DATA_RESULT_LOADER()

        self.data_out_fm_demod = self.tb_result_loader.data[0]['data']
        self.data_out_decimator = []
        self.data_out_audio_mono = self.tb_result_loader.data[1]['data']
        self.data_out_pilot = self.tb_result_loader.data[2]['data']
        self.data_out_carrier_38k = self.tb_result_loader.data[3]['data']
        self.data_out_audio_lrdiff = self.tb_result_loader.data[4]['data']
        self.data_out_audio_L = self.tb_result_loader.data[5]['data']
        self.data_out_audio_R = self.tb_result_loader.data[6]['data']

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

    @cocotb.coroutine
    async def read_fm_demod_output(self):
        sampler = VHDL_SAMPLER("fm_demod", self.dut,
                               self.dut.fm_receiver_inst.fm_demod,
                               self.dut.fm_receiver_inst.fm_demod_valid,
                               self.model.num_samples_fs_c,
                               fp_width_c, fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_fm_demod)

    @cocotb.coroutine
    async def read_decimator_output(self):
        sampler = VHDL_SAMPLER("decimator", self.dut,
                               self.dut.fm_receiver_inst.fm_channel_data,
                               self.dut.fm_receiver_inst.fm_channel_data_valid,
                               self.model.num_samples_c,
                               fp_width_c, fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_decimator)

    @cocotb.coroutine
    async def read_audio_mono_output(self):
        sampler = VHDL_SAMPLER("audio_mono", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_mono,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_mono_valid,
                               self.model.num_samples_audio_c,
                               fp_width_c, fp_width_frac_c, 10)

        await sampler.read_vhdl_output(self.data_out_audio_mono)

    @cocotb.coroutine
    async def read_pilot_output(self):
        sampler = VHDL_SAMPLER("pilot", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.pilot,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.pilot_valid,
                               self.model.num_samples_c,
                               fp_width_c, fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_pilot)

    @cocotb.coroutine
    async def read_carrier_38k_output(self):
        sampler = VHDL_SAMPLER("carrier_38k", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.carrier_38k,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.carrier_38k_valid,
                               self.model.num_samples_c,
                               fp_width_c, fp_width_frac_c)

        await sampler.read_vhdl_output(self.data_out_carrier_38k)

    @cocotb.coroutine
    async def read_audio_lrdiff_output(self):
        sampler = VHDL_SAMPLER("audio_lrdiff", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_lrdiff,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_lrdiff_valid,
                               self.model.num_samples_audio_c,
                               fp_width_c, fp_width_frac_c, 10)

        await sampler.read_vhdl_output(self.data_out_audio_lrdiff)

    @cocotb.coroutine
    async def read_audio_L_output(self):
        sampler_L = VHDL_SAMPLER("audio_L", self.dut,
                                 self.dut.fm_receiver_inst.audio_L_o,
                                 self.dut.fm_receiver_inst.audio_valid_o,
                                 self.model.num_samples_audio_c,
                                 fp_width_c, fp_width_frac_c, 10)

        await sampler_L.read_vhdl_output(self.data_out_audio_L)

    @cocotb.coroutine
    async def read_audio_R_output(self):
        sampler_R = VHDL_SAMPLER("audio_R", self.dut,
                                 self.dut.fm_receiver_inst.audio_R_o,
                                 self.dut.fm_receiver_inst.audio_valid_o,
                                 self.model.num_samples_audio_c,
                                 fp_width_c, fp_width_frac_c, 10)

        await sampler_R.read_vhdl_output(self.data_out_audio_R)

    def compareData(self):
        tb_analyzer_helper = TB_ANALYZER_HELPER(self.model.num_samples_audio_c,
                                                self.model.num_samples_c,
                                                self.model.num_samples_fs_c, is_cocotb=True)
        tb_analyzer_helper.compare_data(self.model, self.tb_result_loader)

        # Shift loaded file-data to compensate shift to testbench-data
        # TODO: why is this necessary?
        #move_n_right(self.model.gold_fm_demod_fp, 2, fp_width_c, fp_width_frac_c)
        #move_n_left(self.model.gold_decimator_fp, 0, fp_width_c, fp_width_frac_c)
        #move_n_left(self.model.gold_pilot_fp, 0, fp_width_c, fp_width_frac_c)
        #move_n_left(self.model.gold_carrier_38k_fp, 0, fp_width_c, fp_width_frac_c)
        #move_n_left(self.model.gold_audio_mono_fp, 5, fp_width_c, fp_width_frac_c)
        #move_n_left(self.model.gold_audio_lrdiff_fp, 5, fp_width_c, fp_width_frac_c)
        #move_n_left(self.model.gold_audio_L_fp, 5, fp_width_c, fp_width_frac_c)
        #move_n_left(self.model.gold_audio_R_fp, 5, fp_width_c, fp_width_frac_c)

        # # Compare
        # self.ok_fm_demod = compareResultsOkay(self.model.gold_fm_demod_fp,
        #                                       self.data_out_fm_demod,
        #                                       fail_on_err=self.EnableFailOnError,
        #                                       max_error_abs=2**-5,
        #                                       max_error_norm=0.06,
        #                                       skip_n_samples_begin=30,
        #                                       skip_n_samples_end=30,
        #                                       data_name="fm_demod")

        # self.ok_decimator = compareResultsOkay(self.model.gold_decimator_fp,
        #                                        self.data_out_decimator,
        #                                        fail_on_err=self.EnableFailOnError,
        #                                        max_error_abs=2**-5,
        #                                        max_error_norm=0.06,
        #                                        skip_n_samples_begin=30,
        #                                        skip_n_samples_end=30,
        #                                        data_name="decimator")

        # self.ok_audio_mono = compareResultsOkay(self.model.gold_audio_mono_fp,
        #                                         self.data_out_audio_mono,
        #                                         fail_on_err=self.EnableFailOnError,
        #                                         max_error_abs=2**-5,
        #                                         max_error_norm=0.06,
        #                                         skip_n_samples_begin=10,
        #                                         skip_n_samples_end=10,
        #                                         data_name="audio_mono")

        # self.ok_pilot = compareResultsOkay(self.model.gold_pilot_fp,
        #                                    self.data_out_pilot,
        #                                    fail_on_err=self.EnableFailOnError,
        #                                    max_error_abs=2**-5,
        #                                    max_error_norm=0.2,
        #                                    skip_n_samples_begin=80,
        #                                    skip_n_samples_end=0,
        #                                    data_name="pilot")

        # self.ok_carrier_38k = compareResultsOkay(self.model.gold_carrier_38k_fp,
        #                                          self.data_out_carrier_38k,
        #                                          fail_on_err=self.EnableFailOnError,
        #                                          max_error_abs=2**-3,
        #                                          max_error_norm=0.5,
        #                                          skip_n_samples_begin=80,
        #                                          skip_n_samples_end=0,
        #                                          data_name="carrier_38k")

        # self.ok_audio_lrdiff = compareResultsOkay(self.model.gold_audio_lrdiff_fp,
        #                                           self.data_out_audio_lrdiff,
        #                                           fail_on_err=self.EnableFailOnError,
        #                                           max_error_abs=2**-5,
        #                                           max_error_norm=0.06,
        #                                           skip_n_samples_begin=10,
        #                                           skip_n_samples_end=10,
        #                                           data_name="audio_lrdiff")

        # self.ok_audio_L = compareResultsOkay(self.model.gold_audio_L_fp,
        #                                      self.data_out_audio_L,
        #                                      fail_on_err=self.EnableFailOnError,
        #                                      max_error_abs=2**-4,
        #                                      max_error_norm=0.06,
        #                                      skip_n_samples_begin=10,
        #                                      skip_n_samples_end=10,
        #                                      data_name="audio_L")

        # self.ok_audio_R = compareResultsOkay(self.model.gold_audio_R_fp,
        #                                      self.data_out_audio_R,
        #                                      fail_on_err=self.EnableFailOnError,
        #                                      max_error_abs=2**-4,
        #                                      max_error_norm=0.06,
        #                                      skip_n_samples_begin=10,
        #                                      skip_n_samples_end=10,
        #                                      data_name="audio_R")

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
        #self.ok_decimator = False

        tn_fs = np.arange(0, self.model.num_samples_fs_c) / fs_c
        tn_rx = np.arange(0, self.model.num_samples_c) / fs_rx_c
        tn_audio = np.arange(0, self.model.num_samples_audio_c) / fs_audio_c
        # -----------------------------------------------------------------
        data = (
            (tn_fs, self.data_out_fm_demod, "data_out_fm_demod"),
            (tn_fs, from_fixed_point(self.model.gold_fm_demod_fp), "gold_fm_demod_fp")
        )
        plotData(data, title="FM Demodulator",
                 filename="sim_build/plot_fm_demod.png",
                 show=(not self.ok_fm_demod))

        # -----------------------------------------------------------------
        data = (
            (tn_rx, self.data_out_decimator, "data_out_decimator"),
            (tn_rx, from_fixed_point(self.model.gold_decimator_fp), "gold_decimator_fp")
        )
        plotData(data, title="Decimator",
                 filename="sim_build/plot_decimator.png",
                 show=(not self.ok_decimator))

        # -----------------------------------------------------------------
        data = (
            (tn_audio, self.data_out_audio_mono, "data_out_audio_mono"),
            (tn_audio, from_fixed_point(self.model.gold_audio_mono_fp), "gold_audio_mono_fp")
        )
        plotData(data, title="Audio Mono",
                 filename="sim_build/plot_audio_mono.png",
                 show=(not self.ok_audio_mono))

        # -----------------------------------------------------------------
        data = (
            (tn_rx, self.data_out_pilot, "data_out_pilot"),
            (tn_rx, from_fixed_point(self.model.gold_pilot_fp), "gold_pilot_fp")
        )
        plotData(data, title="Pilot",
                 filename="sim_build/plot_pilot.png",
                 show=(not self.ok_pilot))

        # -----------------------------------------------------------------
        data = (
            (tn_rx, self.data_out_carrier_38k, "data_out_carrier_38k"),
            (tn_rx, from_fixed_point(self.model.gold_carrier_38k_fp), "gold_carrier_38k_fp")
        )
        plotData(data, title="Carrier 38kHz",
                 filename="sim_build/plot_carrier_38k.png",
                 show=(not self.ok_carrier_38k))

        # -----------------------------------------------------------------
        data = (
            (tn_audio, self.data_out_audio_lrdiff, "data_out_audio_lrdiff"),
            (tn_audio, from_fixed_point(self.model.gold_audio_lrdiff_fp), "gold_audio_lrdiff_fp")
        )
        plotData(data, title="Audio LR Diff",
                 filename="sim_build/plot_audio_lrdiff.png",
                 show=(not self.ok_audio_lrdiff))

        # -----------------------------------------------------------------
        data = (
            (tn_audio, self.data_out_audio_L, "data_out_audio_L"),
            (tn_audio, from_fixed_point(self.model.gold_audio_L_fp), "gold_audio_L_fp")
        )
        plotData(data, title="Audio L",
                 filename="sim_build/plot_audio_L.png",
                 show=(not self.ok_audio_L))

        # -----------------------------------------------------------------
        data = (
            (tn_audio, self.data_out_audio_R, "data_out_audio_R"),
            (tn_audio, from_fixed_point(self.model.gold_audio_R_fp), "gold_audio_R_fp")
        )
        plotData(data, title="Audio R",
                 filename="sim_build/plot_audio_R.png",
                 show=(not self.ok_audio_R))
