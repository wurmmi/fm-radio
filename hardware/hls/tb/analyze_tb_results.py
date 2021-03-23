################################################################################
# File        : analyze_tb_results.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Analyze data output of HLS testbench.
################################################################################


# from fixed_point import *
from helpers import *

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------
# Number of seconds to process
n_sec = 0.010  # TODO: get this from file
EnableFailOnError = False

# Sample rate (NOTE: set according to Matlab model!)
fp_width_c = 16
fp_width_frac_c = 14
fs_rx_c = 120e3
fs_c = 960e3


# Derived constants
num_samples_c = int(n_sec * fs_rx_c)
num_samples_fs_c = int(n_sec * fs_c)


def analyze():
    # --------------------------------------------------------------------------
    # Load data from files
    # --------------------------------------------------------------------------

    # Golden data
    directory_gold = "../../../sim/matlab/verification_data/"

    filename = directory_gold + "rx_fm_demod.txt"
    gold_fm_demod_fp = loadDataFromFile(filename, num_samples_fs_c, fp_width_c, fp_width_frac_c)

    filename = directory_gold + "rx_audio_mono.txt"
    gold_audio_mono_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_gold + "rx_pilot.txt"
    gold_pilot_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_gold + "rx_carrier38kHz.txt"
    gold_carrier_38k_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    # Testbench result data
    directory_tb = "../tb/output/"
    filename = directory_tb + "data_out_fm_demod.txt"
    data_out_fm_demod_fp = loadDataFromFile(filename, num_samples_fs_c, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_audio_mono.txt"
    data_out_audio_mono_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_pilot.txt"
    data_out_pilot_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_carrier_38k.txt"
    data_out_carrier_38k_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    # --------------------------------------------------------------------------
    # Compare data
    # --------------------------------------------------------------------------
    # Shift loaded file-data to compensate shift to testbench-data
    # TODO: why is this necessary?
    move_n_right(gold_pilot_fp, 25, fp_width_c, fp_width_frac_c)
    move_n_left(gold_audio_mono_fp, 13, fp_width_c, fp_width_frac_c)
    move_n_right(gold_carrier_38k_fp, 25, fp_width_c, fp_width_frac_c)

    ok_fm_demod = compareResultsOkay(gold_fm_demod_fp,
                                     from_fixed_point(data_out_fm_demod_fp),
                                     fail_on_err=EnableFailOnError,
                                     max_error_abs=2**-5,
                                     max_error_norm=0.005,
                                     skip_n_samples=30,
                                     data_name="fm_demod",
                                     is_cocotb=False)

    ok_audio_mono = compareResultsOkay(gold_audio_mono_fp,
                                       from_fixed_point(data_out_audio_mono_fp),
                                       fail_on_err=EnableFailOnError,
                                       max_error_abs=2**-5,
                                       max_error_norm=0.5,
                                       skip_n_samples=100,
                                       data_name="audio_mono",
                                       is_cocotb=False)

    ok_pilot = compareResultsOkay(gold_pilot_fp,
                                  from_fixed_point(data_out_pilot_fp),
                                  fail_on_err=EnableFailOnError,
                                  max_error_abs=2**-5,
                                  max_error_norm=0.5,
                                  skip_n_samples=100,
                                  data_name="pilot",
                                  is_cocotb=False)

    ok_carrier_38k = compareResultsOkay(gold_carrier_38k_fp,
                                        from_fixed_point(data_out_carrier_38k_fp),
                                        fail_on_err=EnableFailOnError,
                                        max_error_abs=2**-3,
                                        max_error_norm=0.9,
                                        skip_n_samples=100,
                                        data_name="carrier_38k",
                                        is_cocotb=False)

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------

    # TODO: Enable plots for debug
    #ok_fm_demod = False
    #ok_audio_mono = False
    #ok_pilot = False
    #ok_carrier_38k = False

    tn_fs = np.arange(0, num_samples_fs_c) / fs_c
    tn = np.arange(0, num_samples_c) / fs_rx_c
    # -----------------------------------------------------------------
    data = (
        (tn_fs, from_fixed_point(data_out_fm_demod_fp), "data_out_fm_demod"),
        (tn_fs, from_fixed_point(gold_fm_demod_fp), "gold_fm_demod")
    )
    plotData(data, title="FM Demodulator",
             filename="../tb/output/plot_fm_demod.png",
             show=not ok_fm_demod)
    # -----------------------------------------------------------------
    data = (
        (tn, from_fixed_point(data_out_audio_mono_fp), "data_out_audio_mono"),
        (tn, from_fixed_point(gold_audio_mono_fp), "gold_audio_mono")
    )
    plotData(data, title="Audio Mono",
             filename="../tb/output/plot_audio_mono.png",
             show=not ok_audio_mono)
    # -----------------------------------------------------------------
    data = (
        (tn, from_fixed_point(data_out_pilot_fp), "data_out_pilot"),
        (tn, from_fixed_point(gold_pilot_fp), "gold_pilot")
    )
    plotData(data, title="Pilot",
             filename="../tb/output/plot_pilot.png",
             show=not ok_pilot)
    # -----------------------------------------------------------------
    data = (
        (tn, from_fixed_point(data_out_carrier_38k_fp), "data_out_carrier38k"),
        (tn, from_fixed_point(gold_carrier_38k_fp), "gold_carrier38k")
    )
    plotData(data, title="Carrier 38kHz",
             filename="../tb/output/plot_carrier38k.png",
             show=not ok_carrier_38k)


if __name__ == "__main__":
    analyze()
