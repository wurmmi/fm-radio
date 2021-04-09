################################################################################
# File        : tb_analyzer_helper.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Helper functions for tb_analyzer
################################################################################


import cocotb
import helpers as helper
import numpy as np
from fixed_point import from_fixed_point
from fm_global import *

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------
EnableFailOnError = False


class TB_ANALYZER_HELPER():
    def __init__(self, model, tb_result_loader, is_cocotb):
        # Adapt logging functions
        self.is_cocotb = is_cocotb
        if self.is_cocotb:
            self.log_info = cocotb.log.info
            self.log_warn = cocotb.log.warning
            self.test_fail = cocotb.result.TestFailure
        else:
            self.log_info = print
            self.log_warn = print
            self.test_fail = Exception

        self.model = model
        self.tb_result_loader = tb_result_loader

    def compare_data(self):
        # Shift loaded file-data to compensate shift to testbench-data
        # TODO: why is this necessary?
        if self.is_cocotb:
            self.model.shift_data('fm_demod', 2)
            # self.model.shift_data('decimator', 0)
            self.model.shift_data('pilot', 0)
            self.model.shift_data('carrier_38k', 0)
            self.model.shift_data('audio_mono', -5)
            self.model.shift_data('audio_lrdiff', -5)
            self.model.shift_data('audio_L', -5)
            self.model.shift_data('audio_R', -5)
        else:
            self.model.shift_data('fm_demod', 0)
            # self.model.shift_data('decimator', 0)
            self.model.shift_data('pilot', -16)
            self.model.shift_data('carrier_38k', -16)
            self.model.shift_data('audio_mono', -5)
            self.model.shift_data('audio_lrdiff', -5)
            self.model.shift_data('audio_L', -5)
            self.model.shift_data('audio_R', -5)

        # Compare
        for i in range(0, len(self.model.data)):
            model_dataset = self.model.data[i]
            tb_dataset = self.tb_result_loader.data[i]

            # Sanity check
            msg = "Comparing wrong datasets!! {:>12s} <=> {:12s}\n".format(model_dataset['name'], tb_dataset['name'])
            msg += "Check consistency of the list in TB_DATA_RESULT_LOADER and FM_RECEIVER_MODEL"
            assert model_dataset['name'] == tb_dataset['name'], msg

            tb_dataset['result_okay'] = \
                helper.compareResultsOkay(model_dataset['data'],
                                          tb_dataset['data'],
                                          fail_on_err=EnableFailOnError,
                                          max_error_abs=tb_dataset['max_error_abs'],
                                          max_error_norm=tb_dataset['max_error_norm'],
                                          skip_n_samples_begin=30,  # TODO: get param, or depending on fs
                                          skip_n_samples_end=30,   # TODO: get param, or depending on fs
                                          data_name=tb_dataset['name'],
                                          is_cocotb=self.is_cocotb)

    def generate_plots(self, directory):
        # TODO: Enable plots for debug (check corresponding indexes)
        # self.tb_result_loader.data[0]['result_okay'] = False
        # self.tb_result_loader.data[1]['result_okay'] = False
        # self.tb_result_loader.data[2]['result_okay'] = False
        # self.tb_result_loader.data[3]['result_okay'] = False
        # self.tb_result_loader.data[4]['result_okay'] = False
        # self.tb_result_loader.data[5]['result_okay'] = False
        # self.tb_result_loader.data[6]['result_okay'] = False

        # Plot
        for i in range(0, len(self.model.data)):
            model_dataset = self.model.data[i]
            tb_dataset = self.tb_result_loader.data[i]

            self.log_info(f"Creating plot for {tb_dataset['name']}")

            tn = np.arange(0, len(tb_dataset['data'])) / tb_dataset['fs']
            data_to_plot = (
                (tn, tb_dataset['data'], "data_out_{}".format(tb_dataset['name'])),
                (tn, from_fixed_point(model_dataset['data']), "self.model.gold_{}".format(model_dataset['name']))
            )
            helper.plotData(data_to_plot,
                            title=tb_dataset['name'],
                            filename="{}/plot_{}.png".format(directory, tb_dataset['name']),
                            show=not tb_dataset['result_okay'])
