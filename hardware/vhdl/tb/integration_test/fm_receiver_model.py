################################################################################
# File        : fm_receiver_model.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Model of the FM Receiver IP
################################################################################

import cocotb
from fm_global import *
from helpers import *


class FM_RECEIVER_MODEL(object):
    def __init__(self, n_sec):
        # Derived constants
        self.num_samples_audio_c = int(n_sec * fs_audio_c)
        self.num_samples_c = int(n_sec * fs_rx_c)
        self.num_samples_fs_c = int(n_sec * fs_c)

        self.loadModelData()

    def loadModelData(self):
        directory = "../../../../sim/matlab/verification_data/"

        filename = directory + "rx_fm_demod.txt"
        self.gold_fm_demod_fp = loadDataFromFile(filename, self.num_samples_fs_c, fp_width_c, fp_width_frac_c)

        filename = directory + "rx_fmChannelData.txt"
        self.gold_decimator_fp = loadDataFromFile(filename, self.num_samples_c, fp_width_c, fp_width_frac_c)

        filename = directory + "rx_audio_mono.txt"
        self.gold_audio_mono_fp = loadDataFromFile(filename, self.num_samples_audio_c, fp_width_c, fp_width_frac_c)

        filename = directory + "rx_pilot.txt"
        self.gold_pilot_fp = loadDataFromFile(filename, self.num_samples_c, fp_width_c, fp_width_frac_c)

        filename = directory + "rx_carrier38kHz.txt"
        self.gold_carrier_38k_fp = loadDataFromFile(filename, self.num_samples_c, fp_width_c, fp_width_frac_c)

        filename = directory + "rx_audio_lrdiff.txt"
        self.gold_audio_lrdiff_fp = loadDataFromFile(filename, self.num_samples_audio_c, fp_width_c, fp_width_frac_c)

        filename = directory + "rx_audio_L.txt"
        self.gold_audio_L_fp = loadDataFromFile(filename, self.num_samples_audio_c, fp_width_c, fp_width_frac_c)

        filename = directory + "rx_audio_R.txt"
        self.gold_audio_R_fp = loadDataFromFile(filename, self.num_samples_audio_c, fp_width_c, fp_width_frac_c)

        cocotb.log.info("num_samples_fs: {}, num_samples: {}, num_samples_audio: {} ".format(
            self.num_samples_fs_c, self.num_samples_c, self.num_samples_audio_c))
