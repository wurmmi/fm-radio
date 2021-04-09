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

        # Sanity checks
        assert (self.CLOCK_FREQ_MHZ * 1e9 / fs_rx_c).is_integer(), \
            "Clock rate and fs_rx_c must have an integer relation!"

        # Instantiate model
        golden_data_directory = "../../../../sim/matlab/verification_data/"
        self.model = FM_RECEIVER_MODEL(n_sec, golden_data_directory)

        # Connect AXI interface
        slave_interface_to_connect_to = "s0_axis"
        self.axis_m = Axi4StreamMaster(dut, slave_interface_to_connect_to, dut.clk_i)

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

        self.tb_analyzer_helper = TB_ANALYZER_HELPER(self.model, self.tb_result_loader, is_cocotb=True)

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
        self.tb_analyzer_helper.compare_data()

    def generatePlots(self):
        if not self.EnablePlots:
            return

        directory_plot_output = "./sim_build"
        self.tb_analyzer_helper.generate_plots(directory_plot_output)
