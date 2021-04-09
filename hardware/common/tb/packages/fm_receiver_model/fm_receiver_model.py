################################################################################
# File        : fm_receiver_model.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Model of the FM Receiver IP
################################################################################

import cocotb
from fm_global import *
from helpers import *


class FM_RECEIVER_MODEL():
    def __init__(self, n_sec, golden_data_directory, is_cocotb=True):
        # Adapt logging functions
        if is_cocotb:
            self.log_info = cocotb.log.info
            self.log_warn = cocotb.log.warning
            self.test_fail = cocotb.result.TestFailure
        else:
            self.log_info = print
            self.log_warn = print
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
                'data': loadDataFromFile(directory + "rx_fm_demod.txt", self.num_samples_fs_c, fp_width_c, fp_width_frac_c)
            },
            # {
            #    'name': 'decimator',
            #    'data': loadDataFromFile(directory + "rx_fmChannelData.txt", self.num_samples_c, fp_width_c, fp_width_frac_c)
            # },
            {
                'name': 'audio_mono',
                'data': loadDataFromFile(directory + "rx_audio_mono.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'pilot',
                'data': loadDataFromFile(directory + "rx_pilot.txt", self.num_samples_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'carrier_38k',
                'data': loadDataFromFile(directory + "rx_carrier38kHz.txt", self.num_samples_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'audio_lrdiff',
                'data': loadDataFromFile(directory + "rx_audio_lrdiff.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'audio_L',
                'data': loadDataFromFile(directory + "rx_audio_L.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            },
            {
                'name': 'audio_R',
                'data': loadDataFromFile(directory + "rx_audio_R.txt", self.num_samples_audio_c, fp_width_c, fp_width_frac_c)
            }
        ]

        self.log_info("Loaded data! num_samples_fs: {}, num_samples: {}, num_samples_audio: {} ".format(
            self.num_samples_fs_c, self.num_samples_c, self.num_samples_audio_c))

    def shift_data(self, data_name, amount):
        # Find the dataset to be shifted
        dataset = [x for x in self.data if x['name'] == data_name]
        if len(dataset) == 0:
            raise self.test_fail("Could not find dataset with name: '{}' !!".format(data_name))

        dataset = dataset[0]['data']
        # Shift
        if amount >= 0:
            move_n_right(dataset, amount, fp_width_c, fp_width_frac_c)
        else:
            move_n_left(dataset, -amount, fp_width_c, fp_width_frac_c)
