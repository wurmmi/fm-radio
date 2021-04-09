################################################################################
# File        : fm_receiver_model.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Model of the FM Receiver IP
################################################################################

import cocotb
import helpers as helper
from fm_global import *
from tb_data_result_loader import TB_DATA_RESULT_LOADER


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
        self.n_sec = n_sec
        self.num_samples_audio_c = int(n_sec * fs_audio_c)
        self.num_samples_rx_c = int(n_sec * fs_rx_c)
        self.num_samples_fs_c = int(n_sec * fs_c)

        self.loadModelData(golden_data_directory)

        self.log_info("Loaded data! num_samples_fs: {}, num_samples: {}, num_samples_audio: {} ".format(
            self.num_samples_fs_c, self.num_samples_rx_c, self.num_samples_audio_c))

    def loadModelData(self, directory):
        temp = TB_DATA_RESULT_LOADER()

        self.data = []
        for dataset in temp.data:
            filename = directory + "rx_{}.txt".format(dataset['name'])
            num_samples = int(self.n_sec * dataset['fs'])

            new_dataset = {}
            new_dataset['name'] = dataset['name']
            new_dataset['data'] = helper.loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)
            self.data.append(new_dataset)

    def shift_data(self, data_name, amount):
        # Find the dataset to be shifted
        dataset = helper.get_dataset_by_name(self.data, data_name, self.log_error)

        # Shift
        if amount >= 0:
            helper.move_n_right(dataset, amount, fp_width_c, fp_width_frac_c)
        else:
            helper.move_n_left(dataset, -amount, fp_width_c, fp_width_frac_c)
