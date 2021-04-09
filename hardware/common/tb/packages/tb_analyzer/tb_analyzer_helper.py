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
    def __init__(self, num_samples_audio, num_samples, num_samples_fs):
        self.num_samples_audio_c = num_samples_audio
        self.num_samples_c = num_samples
        self.num_samples_fs_c = num_samples_fs

    def compare_data(self, model, tb_result_loader):
        # Shift loaded file-data to compensate shift to testbench-data
        # TODO: why is this necessary?
        move_n_left(model.gold_pilot_fp, 16, fp_width_c, fp_width_frac_c)
        move_n_left(model.gold_carrier_38k_fp, 16, fp_width_c, fp_width_frac_c)
        move_n_left(model.gold_audio_mono_fp, 5, fp_width_c, fp_width_frac_c)
        move_n_left(model.gold_audio_lrdiff_fp, 5, fp_width_c, fp_width_frac_c)
        move_n_left(model.gold_audio_L_fp, 5, fp_width_c, fp_width_frac_c)
        move_n_left(model.gold_audio_R_fp, 5, fp_width_c, fp_width_frac_c)

        # Compare
        tb_dataset = [x for x in tb_data if x['name'] == 'fm_demod'][0]
        self.ok_fm_demod = compareResultsOkay(model.gold_fm_demod_fp,
                                              from_fixed_point(tb_dataset['data']),
                                              fail_on_err=EnableFailOnError,
                                              max_error_abs=2**-5,
                                              max_error_norm=0.06,
                                              skip_n_samples_begin=30,
                                              skip_n_samples_end=30,
                                              data_name="fm_demod",
                                              is_cocotb=False)

        tb_dataset = [x for x in tb_data if x['name'] == 'audio_mono'][0]
        self.ok_audio_mono = compareResultsOkay(model.gold_audio_mono_fp,
                                                from_fixed_point(tb_dataset['data']),
                                                fail_on_err=EnableFailOnError,
                                                max_error_abs=2**-5,
                                                max_error_norm=0.6,
                                                skip_n_samples_begin=100,
                                                skip_n_samples_end=100,
                                                data_name="audio_mono",
                                                is_cocotb=False)

        tb_dataset = [x for x in tb_data if x['name'] == 'pilot'][0]
        self.ok_pilot = compareResultsOkay(model.gold_pilot_fp,
                                           from_fixed_point(tb_dataset['data']),
                                           fail_on_err=EnableFailOnError,
                                           max_error_abs=0.5,
                                           max_error_norm=3.0,
                                           skip_n_samples_begin=100,
                                           skip_n_samples_end=100,
                                           data_name="pilot",
                                           is_cocotb=False)

        tb_dataset = [x for x in tb_data if x['name'] == 'carrier_38k'][0]
        self.ok_carrier_38k = compareResultsOkay(model.gold_carrier_38k_fp,
                                                 from_fixed_point(tb_dataset['data']),
                                                 fail_on_err=EnableFailOnError,
                                                 max_error_abs=0.7,
                                                 max_error_norm=7.5,
                                                 skip_n_samples_begin=100,
                                                 skip_n_samples_end=100,
                                                 data_name="carrier_38k",
                                                 is_cocotb=False)

        tb_dataset = [x for x in tb_data if x['name'] == 'audio_lrdiff'][0]
        self.ok_audio_lrdiff = compareResultsOkay(model.gold_audio_lrdiff_fp,
                                                  from_fixed_point(tb_dataset['data']),
                                                  fail_on_err=EnableFailOnError,
                                                  max_error_abs=2**-3,
                                                  max_error_norm=0.9,
                                                  skip_n_samples_begin=100,
                                                  skip_n_samples_end=100,
                                                  data_name="audio_lrdiff",
                                                  is_cocotb=False)

        tb_dataset = [x for x in tb_data if x['name'] == 'audio_L'][0]
        self.ok_audio_L = compareResultsOkay(model.gold_audio_L_fp,
                                             from_fixed_point(tb_dataset['data']),
                                             fail_on_err=EnableFailOnError,
                                             max_error_abs=2**-3,
                                             max_error_norm=0.9,
                                             skip_n_samples_begin=100,
                                             skip_n_samples_end=100,
                                             data_name="audio_L",
                                             is_cocotb=False)

        tb_dataset = [x for x in tb_data if x['name'] == 'audio_R'][0]
        self.ok_audio_R = compareResultsOkay(model.gold_audio_R_fp,
                                             from_fixed_point(tb_dataset['data']),
                                             fail_on_err=EnableFailOnError,
                                             max_error_abs=2**-3,
                                             max_error_norm=0.9,
                                             skip_n_samples_begin=100,
                                             skip_n_samples_end=100,
                                             data_name="audio_R",
                                             is_cocotb=False)

    def generate_plots(self, model, tb_data):
        # TODO: Enable plots for debug
        #self.ok_fm_demod = False
        #self.ok_audio_mono = False
        #self.ok_pilot = False
        #self.ok_carrier_38k = False
        #self.ok_audio_lrdiff = False
        #self.ok_audio_L = False
        #self.ok_audio_R = False

        tn_fs = np.arange(0, self.num_samples_fs_c) / fs_c
        tn = np.arange(0, self.num_samples_c) / fs_rx_c
        tn_audio = np.arange(0, self.num_samples_audio_c) / fs_audio_c
        # -----------------------------------------------------------------
        tb_dataset = [x for x in tb_data if x['name'] == 'fm_demod'][0]
        data = (
            (tn_fs, from_fixed_point(tb_dataset['data']), "data_out_fm_demod"),
            (tn_fs, from_fixed_point(model.gold_fm_demod_fp), "model.gold_fm_demod")
        )
        plotData(data, title="FM Demodulator",
                 filename="../tb/output/plot_fm_demod.png",
                 show=not self.ok_fm_demod)
        # -----------------------------------------------------------------
        tb_dataset = [x for x in tb_data if x['name'] == 'audio_mono'][0]
        data = (
            (tn_audio, from_fixed_point(tb_dataset['data']), "data_out_audio_mono"),
            (tn_audio, from_fixed_point(model.gold_audio_mono_fp), "model.gold_audio_mono")
        )
        plotData(data, title="Audio Mono",
                 filename="../tb/output/plot_audio_mono.png",
                 show=not self.ok_audio_mono)
        # -----------------------------------------------------------------
        tb_dataset = [x for x in tb_data if x['name'] == 'pilot'][0]
        data = (
            (tn, from_fixed_point(tb_dataset['data']), "data_out_pilot"),
            (tn, from_fixed_point(model.gold_pilot_fp), "model.gold_pilot")
        )
        plotData(data, title="Pilot",
                 filename="../tb/output/plot_pilot.png",
                 show=not self.ok_pilot)
        # -----------------------------------------------------------------
        tb_dataset = [x for x in tb_data if x['name'] == 'carrier_38k'][0]
        data = (
            (tn, from_fixed_point(tb_dataset['data']), "data_out_carrier_38k"),
            (tn, from_fixed_point(model.gold_carrier_38k_fp), "model.gold_carrier_38k")
        )
        plotData(data, title="Carrier 38kHz",
                 filename="../tb/output/plot_carrier_38k.png",
                 show=not self.ok_carrier_38k)
        # -----------------------------------------------------------------
        tb_dataset = [x for x in tb_data if x['name'] == 'audio_lrdiff'][0]
        data = (
            (tn_audio, from_fixed_point(tb_dataset['data']), "data_out_audio_lrdiff"),
            (tn_audio, from_fixed_point(model.gold_audio_lrdiff_fp), "model.gold_audio_lrdiff")
        )
        plotData(data, title="Audio LR diff",
                 filename="../tb/output/plot_audio_lrdiff.png",
                 show=not self.ok_audio_lrdiff)
        # -----------------------------------------------------------------
        tb_dataset = [x for x in tb_data if x['name'] == 'audio_L'][0]
        data = (
            (tn_audio, from_fixed_point(tb_dataset['data']), "data_out_audio_L"),
            (tn_audio, from_fixed_point(model.gold_audio_L_fp), "model.gold_audio_L")
        )
        plotData(data, title="Audio L",
                 filename="../tb/output/plot_audio_L.png",
                 show=not self.ok_audio_L)

        # -----------------------------------------------------------------
        tb_dataset = [x for x in tb_data if x['name'] == 'audio_R'][0]
        data = (
            (tn_audio, from_fixed_point(tb_dataset['data']), "data_out_audio_R"),
            (tn_audio, from_fixed_point(model.gold_audio_R_fp), "model.gold_audio_R")
        )
        plotData(data, title="Audio R",
                 filename="../tb/output/plot_audio_R.png",
                 show=not self.ok_audio_R)
