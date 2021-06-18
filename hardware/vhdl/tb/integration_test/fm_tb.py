################################################################################
# File        : fm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench environment
################################################################################


import cocotb
import fm_global
import helpers as helper
from cocotb.drivers import BitDriver
from cocotb.triggers import RisingEdge, Timer
from cocotbext.axi4stream.drivers import Axi4StreamMaster
from fm_receiver_model import FM_RECEIVER_MODEL
from tb_analyzer_helper import TB_ANALYZER_HELPER
from tb_data_handler import TB_DATA_HANDLER
from vhdl_sampler import VHDL_SAMPLER


class FM_TB():
    # Constants
    CLOCK_FREQ_MHZ = 48
    EnableFailOnError = False
    EnablePlots = True

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject, n_sec):
        self.dut = dut

        # Sanity checks
        assert (self.CLOCK_FREQ_MHZ * 1e9 / fm_global.fs_rx_c).is_integer(), \
            "Clock rate and fs_rx_c must have an integer relation!"

        # Instantiate model
        golden_data_directory = "../../../../sim/matlab/verification_data/"
        self.model = FM_RECEIVER_MODEL(n_sec, golden_data_directory)

        # Connect AXI interface (IP input)
        self.axis_m = Axi4StreamMaster(dut, "s0_axis", dut.clk_i)

        # Backpressure from I2S output
        self.backpressure_i2s = BitDriver(dut.m0_axis_tready, dut.clk_i)

        # Variables
        self.tb_data_handler = TB_DATA_HANDLER()
        self.tb_analyzer_helper = TB_ANALYZER_HELPER(self.model, self.tb_data_handler, is_cocotb=True)

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
                               fm_global.fp_width_c, fm_global.fp_width_frac_c)
        await sampler.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'fm_demod'))

    @cocotb.coroutine
    async def read_fm_channel_data_output(self):
        sampler = VHDL_SAMPLER("fm_channel_data", self.dut,
                               self.dut.fm_receiver_inst.fm_channel_data,
                               self.dut.fm_receiver_inst.fm_channel_data_valid,
                               self.model.num_samples_rx_c,
                               fm_global.fp_width_c, fm_global.fp_width_frac_c)

        await sampler.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'fm_channel_data'))

    @cocotb.coroutine
    async def read_audio_mono_output(self):
        sampler = VHDL_SAMPLER("audio_mono", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_mono,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_mono_valid,
                               self.model.num_samples_audio_c,
                               fm_global.fp_width_c, fm_global.fp_width_frac_c, 10)

        await sampler.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'audio_mono'))

    @cocotb.coroutine
    async def read_pilot_output(self):
        sampler = VHDL_SAMPLER("pilot", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.pilot,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.pilot_valid,
                               self.model.num_samples_rx_c,
                               fm_global.fp_width_c, fm_global.fp_width_frac_c)

        await sampler.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'pilot'))

    @cocotb.coroutine
    async def read_carrier_38k_output(self):
        sampler = VHDL_SAMPLER("carrier_38k", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.carrier_38k,
                               self.dut.fm_receiver_inst.channel_decoder_inst.recover_carriers_inst.carrier_38k_valid,
                               self.model.num_samples_rx_c,
                               fm_global.fp_width_c, fm_global.fp_width_frac_c)

        await sampler.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'carrier_38k'))

    @cocotb.coroutine
    async def read_audio_lrdiff_output(self):
        sampler = VHDL_SAMPLER("audio_lrdiff", self.dut,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_lrdiff,
                               self.dut.fm_receiver_inst.channel_decoder_inst.audio_lrdiff_valid,
                               self.model.num_samples_audio_c,
                               fm_global.fp_width_c, fm_global.fp_width_frac_c, 10)

        await sampler.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'audio_lrdiff'))

    @cocotb.coroutine
    async def read_audio_output(self):
        pass
        # sampler = VHDL_SAMPLER("audio_out", self.dut,
        #                       self.dut.m0_axis_tdata,
        #                       self.dut.m0_axis_tvalid,
        #                       self.model.num_samples_audio_c,
        #                       fm_global.fp_width_c, fm_global.fp_width_frac_c, 10)
        #
        #data_L = helper.get_dataset_by_name(self.tb_data_handler.data, 'audio_L')
        #data_R = helper.get_dataset_by_name(self.tb_data_handler.data, 'audio_R')
        #
        # TODO: split upper and lower 16 bit first
        # data_L.append(read_data)
        # data_R.append(read_data)

    @cocotb.coroutine
    async def read_audio_L_output(self):
        sampler_L = VHDL_SAMPLER("audio_L", self.dut,
                                 self.dut.fm_receiver_inst.audio_L_o,
                                 self.dut.fm_receiver_inst.audio_valid_o,
                                 self.model.num_samples_audio_c,
                                 fm_global.fp_width_c, fm_global.fp_width_frac_c, 10)

        await sampler_L.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'audio_L'))

    @cocotb.coroutine
    async def read_audio_R_output(self):
        sampler_R = VHDL_SAMPLER("audio_R", self.dut,
                                 self.dut.fm_receiver_inst.audio_R_o,
                                 self.dut.fm_receiver_inst.audio_valid_o,
                                 self.model.num_samples_audio_c,
                                 fm_global.fp_width_c, fm_global.fp_width_frac_c, 10)

        await sampler_R.read_vhdl_output(
            helper.get_dataset_by_name(self.tb_data_handler.data, 'audio_R'))

    def compareData(self):
        self.tb_analyzer_helper.compare_data()

    def generatePlots(self):
        if not self.EnablePlots:
            return

        directory_plot_output = "./sim_build"
        self.tb_analyzer_helper.generate_plots(directory_plot_output)
