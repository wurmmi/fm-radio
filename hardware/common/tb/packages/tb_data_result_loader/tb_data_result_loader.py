################################################################################
# File        : tb_data_result_loader.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Data results from testbench.
#               Loads the from file, or gets it from cocotb.
################################################################################

from fixed_point import *
from fm_global import *
from helpers import loadDataFromFile


class TB_DATA_RESULT_LOADER():
    def __init__(self):
        #######
        # NOTE: Keep this list consistent with the list in FM_RECEIVER_MODEL !
        #######
        self.data = [
            {
                'name': "fm_demod",
                'data': [],
                'fs': fs_c,
                'max_error_abs': 2**-5,
                'max_error_norm': 0.06,
                'result_okay': False
            },
            {
                'name': "audio_mono",
                'data': [],
                'fs': fs_audio_c,
                'max_error_abs': 2**-5,
                'max_error_norm': 0.6,  # todo
                'result_okay': False
            },
            {
                'name': "pilot",
                'data': [],
                'fs': fs_rx_c,
                'max_error_abs': 0.5,  # todo vhdl 2**-5
                'max_error_norm': 3.2,  # todo vhdl 0.2
                'result_okay': False
            },
            {
                'name': "carrier_38k",
                'data': [],
                'fs': fs_rx_c,
                'max_error_abs': 0.5,  # todo 0.7 vhdl 2**-3
                'max_error_norm': 7.5,  # todo vhdl 0.5
                'result_okay': False
            },
            {
                'name': "audio_lrdiff",
                'data': [],
                'fs': fs_audio_c,
                'max_error_abs': 2**-3,  # vhdl 2**-5
                'max_error_norm': 0.9,  # todo vhdl 0.06
                'result_okay': False
            },
            {
                'name': "audio_L",
                'data': [],
                'fs': fs_audio_c,
                'max_error_abs': 2**-3,  # vhdl 2**-4
                'max_error_norm': 0.9,  # todo vhdl 0.06
                'result_okay': False
            },
            {
                'name': "audio_R",
                'data': [],
                'fs': fs_audio_c,
                'max_error_abs': 2**-3,  # vhdl 2**-4
                'max_error_norm': 0.9,  # todo vhdl 0.06
                'result_okay': False
            }
        ]

    def load_data_from_file(self, directory):
        for dataset in self.data:
            filename = directory + f"data_out_{dataset['name']}.txt"
            dataset['data'] = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c, use_fixed=False)
