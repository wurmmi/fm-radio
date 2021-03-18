################################################################################
# File        : fm_receiver_model.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Model of the FM Receiver IP
################################################################################

import cocotb
from helpers import *


class FM_RECEIVER_MODEL(object):
    def __init__(self, n_sec, fp_width, fp_width_frac):
        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac

        # Sample rate (NOTE: set according to Matlab model!)
        self.FS_RX_KHZ = 120
        self.FS_KHZ = 960

        # Derived constants
        self.num_samples_c = int(n_sec * self.FS_RX_KHZ * 1000)
        self.num_samples_fs_c = int(n_sec * self.FS_KHZ * 1000)

        self.loadModelData()

    def loadModelData(self):
        filename = "../../../sim/matlab/verification_data/rx_fm_demod.txt"
        self.gold_fm_demod_fp = loadDataFromFile(filename, self.num_samples_fs_c, self.fp_width_c, self.fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_fmChannelData.txt"
        self.gold_decimator_fp = loadDataFromFile(filename, self.num_samples_c, self.fp_width_c, self.fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_audio_mono.txt"
        self.gold_audio_mono_fp = loadDataFromFile(filename, self.num_samples_c, self.fp_width_c, self.fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_pilot.txt"
        self.gold_pilot_fp = loadDataFromFile(filename, self.num_samples_c, self.fp_width_c, self.fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_carrier38kHz.txt"
        self.gold_carrier_38k_fp = loadDataFromFile(filename, self.num_samples_c, self.fp_width_c, self.fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_audio_lrdiff.txt"
        self.gold_audio_lrdiff_fp = loadDataFromFile(
            filename, self.num_samples_c, self.fp_width_c, self.fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_audio_L.txt"
        self.gold_audio_L_fp = loadDataFromFile(filename, self.num_samples_c, self.fp_width_c, self.fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_audio_R.txt"
        self.gold_audio_R_fp = loadDataFromFile(filename, self.num_samples_c, self.fp_width_c, self.fp_width_frac_c)

        cocotb.log.info("num_samples_fs: {}, num_samples: {} ".format(self.num_samples_fs_c, self.num_samples_c))
