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
        pass

    def load_data_from_file(self, directory):
        #######
        # NOTE: Keep this list consistent with the list in FM_RECEIVER_MODEL !
        #######
        self.data = [
            {
                'name': "fm_demod",
                'data': loadDataFromFile(directory + "data_out_fm_demod.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_c,
                'max_error_abs': 2**-5,
                'max_error_norm': 0.06,
                'result_okay': False
            },
            {
                'name': "audio_mono",
                'data': loadDataFromFile(directory + "data_out_audio_mono.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c,
                'max_error_abs': 2**-5,
                'max_error_norm': 0.6,  # todo
                'result_okay': False
            },
            {
                'name': "pilot",
                'data': loadDataFromFile(directory + "data_out_pilot.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_rx_c,
                'max_error_abs': 0.5,  # todo
                'max_error_norm': 3.2,  # todo
                'result_okay': False
            },
            {
                'name': "carrier_38k",
                'data': loadDataFromFile(directory + "data_out_carrier_38k.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_rx_c,
                'max_error_abs': 0.5,  # 0.7
                'max_error_norm': 7.5,  # todo
                'result_okay': False
            },
            {
                'name': "audio_lrdiff",
                'data': loadDataFromFile(directory + "data_out_audio_lrdiff.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c,
                'max_error_abs': 2**-3,
                'max_error_norm': 0.9,  # todo
                'result_okay': False
            },
            {
                'name': "audio_L",
                'data': loadDataFromFile(directory + "data_out_audio_L.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c,
                'max_error_abs': 2**-3,
                'max_error_norm': 0.9,  # todo
                'result_okay': False
            },
            {
                'name': "audio_R",
                'data': loadDataFromFile(directory + "data_out_audio_R.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c,
                'max_error_abs': 2**-3,
                'max_error_norm': 0.9,  # todo
                'result_okay': False
            }
        ]
