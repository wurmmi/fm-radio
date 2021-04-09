################################################################################
# File        : tb_analyzer_helper.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Helper functions for tb_analyzer
################################################################################


from fixed_point import *
from fm_global import *
from helpers import *

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------
EnableFailOnError = False


class TB_ANALYZER_HELPER():
    def __init__(self, num_samples_audio, num_samples, num_samples_fs, is_cocotb):
        # Adapt logging functions
        self.is_cocotb = is_cocotb
        if is_cocotb:
            self.log_info = cocotb.log.info
            self.log_warn = cocotb.log.warning
            self.test_fail = cocotb.result.TestFailure
        else:
            self.log_info = print
            self.log_warn = print
            self.test_fail = Exception

        self.num_samples_audio_c = num_samples_audio
        self.num_samples_c = num_samples
        self.num_samples_fs_c = num_samples_fs

    def compare_data(self, model, tb_result_loader):
        # Shift loaded file-data to compensate shift to testbench-data
        # TODO: why is this necessary?
        model.shift_data('fm_demod', -0)
        # model.shift_data('decimator', -0)
        model.shift_data('pilot', -16)
        model.shift_data('carrier_38k', -16)
        model.shift_data('audio_mono', -5)
        model.shift_data('audio_lrdiff', -5)
        model.shift_data('audio_L', -5)
        model.shift_data('audio_R', -5)

        # Compare
        for i in range(0, len(model.data)):
            model_dataset = model.data[i]
            tb_dataset = tb_result_loader.data[i]
            self.log_info("Comparing {:>12s} <=> {:12s}".format(model_dataset['name'], tb_dataset['name']))

            tb_dataset['result_okay'] = compareResultsOkay(model_dataset['data'],
                                                           from_fixed_point(tb_dataset['data']),
                                                           fail_on_err=EnableFailOnError,
                                                           max_error_abs=tb_dataset['max_error_abs'],
                                                           max_error_norm=tb_dataset['max_error_norm'],
                                                           skip_n_samples_begin=30,
                                                           skip_n_samples_end=30,
                                                           data_name=tb_dataset['name'],
                                                           is_cocotb=self.is_cocotb)

    def generate_plots(self, model, tb_result_loader):
        # TODO: Enable plots for debug
        # self.ok_fm_demod = False
        # self.ok_audio_mono = False
        # self.ok_pilot = False
        # self.ok_carrier_38k = False
        # self.ok_audio_lrdiff = False
        # self.ok_audio_L = False
        # self.ok_audio_R = False

        # Plot
        for i in range(0, len(model.data)):
            model_dataset = model.data[i]
            tb_dataset = tb_result_loader.data[i]

            tn = np.arange(0, len(tb_dataset['data'])) / tb_dataset['fs']

            data_to_plot = (
                (tn, from_fixed_point(tb_dataset['data']), "data_out_{}".format(tb_dataset['name'])),
                (tn, from_fixed_point(model_dataset['data']), "model.gold_{}".format(model_dataset['name']))
            )
            plotData(data_to_plot,
                     title=tb_dataset['name'],
                     filename="../tb/output/plot_{}.png".format(tb_dataset['name']),
                     show=not tb_dataset['result_okay'])
