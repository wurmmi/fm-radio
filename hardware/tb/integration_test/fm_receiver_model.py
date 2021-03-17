################################################################################
# File        : fm_receiver_model.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Model of the FM Receiver IP
################################################################################

import cocotb
from helpers import *


class FM_RECEIVER_MODEL(object):
    def __init__(self):
        pass
        # self.loadModelData()

    def loadModelData(self):
        filename = "../../../sim/matlab/verification_data/rx_fm_demod.txt"
        self.fm_demod_gold_fp = loadDataFromFile(filename, num_samples_fs, fp_width_c, fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_audio_mono.txt"
        self.audio_mono_gold_fp = loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_pilot.txt"
        self.pilot_gold_fp = loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_carrier38kHz.txt"
        self.carrier_38k_gold_fp = loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)

        filename = "../../../sim/matlab/verification_data/rx_audio_lrdiff.txt"
        self.audio_lrdiff_gold_fp = loadDataFromFile(filename, num_samples, fp_width_c, fp_width_frac_c)
