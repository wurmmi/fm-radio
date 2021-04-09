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
        self.data = [
            {
                'name': "fm_demod",
                'data': loadDataFromFile(directory + "data_out_fm_demod.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_c
            },
            {
                'name': "audio_mono",
                'data': loadDataFromFile(directory + "data_out_audio_mono.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c
            },
            {
                'name': "pilot",
                'data': loadDataFromFile(directory + "data_out_pilot.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_rx_c
            },
            {
                'name': "carrier_38k",
                'data': loadDataFromFile(directory + "data_out_carrier_38k.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_rx_c
            },
            {
                'name': "audio_lrdiff",
                'data': loadDataFromFile(directory + "data_out_audio_lrdiff.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c
            },
            {
                'name': "audio_L",
                'data': loadDataFromFile(directory + "data_out_audio_L.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c
            },
            {
                'name': "audio_R",
                'data': loadDataFromFile(directory + "data_out_audio_R.txt", -1, fp_width_c, fp_width_frac_c),
                'fs': fs_audio_c
            }
        ]
