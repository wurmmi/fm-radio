################################################################################
# File        : fm_receiver_model.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Model of the FM Receiver IP
################################################################################

import cocotb
import helpers as helper
from fm_global import *


class FM_RECEIVER_MODEL():
    def __init__(self, n_sec, golden_data_directory, is_cocotb=True):
        # Adapt logging functions
        if is_cocotb:
            self.log_info = cocotb.logging.info
            self.log_warn = cocotb.logging.warning
            self.log_error = cocotb.logging.error
            self.test_fail = cocotb.result.TestFailure
        else:
            self.log_info = print
            self.log_warn = print
            self.log_error = print
            self.test_fail = Exception

        # Derived constants
        self.num_samples_audio_c = int(n_sec * fs_audio_c)
        self.num_samples_c = int(n_sec * fs_rx_c)
        self.num_samples_fs_c = int(n_sec * fs_c)

        if n_sec == -1:
            self.num_samples_audio_c = -1
            self.num_samples_c = -1
            self.num_samples_fs_c = -1

        self.loadModelData(golden_data_directory)

    def loadModelData(self, directory):
        #######
        # NOTE: Keep this list consistent with the list in TB_DATA_RESULT_LOADER !
        #######
        self.data = [
            {
                'name': 'fm_demod',
                'data': helper.loadDataFromFile(directory + "rx_fm_demod.txt", self.num_samples_fs_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'fm_channel_data',
                'data': helper.loadDataFromFile(directory + "rx_fm_channel_data.txt", self.num_samples_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'audio_mono',
                'data': helper.loadDataFromFile(directory + "rx_audio_mono.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'pilot',
                'data': helper.loadDataFromFile(directory + "rx_pilot.txt", self.num_samples_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'carrier_38k',
                'data': helper.loadDataFromFile(directory + "rx_carrier38kHz.txt", self.num_samples_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'audio_lrdiff',
                'data': helper.loadDataFromFile(directory + "rx_audio_lrdiff.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'audio_L',
                'data': helper.loadDataFromFile(directory + "rx_audio_L.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'audio_R',
                'data': helper.loadDataFromFile(directory + "rx_audio_R.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            }
        ]

        self.log_info("Loaded data! num_samples_fs: {}, num_samples: {}, num_samples_audio: {} ".format(
            self.num_samples_fs_c, self.num_samples_c, self.num_samples_audio_c))

    def shift_data(self, data_name, amount):
        # Find the dataset to be shifted
        dataset = helper.get_dataset_by_name(self.data, data_name, self.log_error)

        # Shift
        if amount >= 0:
            helper.move_n_right(dataset, amount, fp_width_c, fp_width_frac_c)
        else:
            helper.move_n_left(dataset, -amount, fp_width_c, fp_width_frac_c)
