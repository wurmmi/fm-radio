################################################################################
# File        : analyze_tb_results.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Analyze data output of HLS testbench.
################################################################################


from fm_global import *
from helpers import *

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------
EnableFailOnError = False


def analyze():
    print("===============================================")
    print("### Running analysis ...")
    print("===============================================")

    # --------------------------------------------------------------------------
    # Load data from files
    # --------------------------------------------------------------------------
    print("--- Loading data from files")

    # Testbench result data
    directory_tb = "../tb/output/"
    filename = directory_tb + "data_out_fm_demod.txt"
    data_out_fm_demod_fp = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_audio_mono.txt"
    data_out_audio_mono_fp = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_pilot.txt"
    data_out_pilot_fp = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_carrier_38k.txt"
    data_out_carrier_38k_fp = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_audio_lrdiff.txt"
    data_out_audio_lrdiff_fp = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_audio_L.txt"
    data_out_audio_L_fp = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_audio_R.txt"
    data_out_audio_R_fp = loadDataFromFile(filename, -1, fp_width_c, fp_width_frac_c)

    # Check number of samples that were found in the files
    num_samples_c = len(data_out_pilot_fp)
    num_samples_fs_c = len(data_out_fm_demod_fp)

    # Sanity checks
    assert num_samples_fs_c // num_samples_c == osr_rx_c, \
        "File lengths don't match osr_rx_c ..."

    n_sec = num_samples_c / fs_rx_c
    print(f"Loaded {n_sec} seconds worth of data.")

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

    filename = directory_gold + "rx_audio_lrdiff.txt"
    gold_audio_lrdiff_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_gold + "rx_audio_L.txt"
    gold_audio_L_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_gold + "rx_audio_R.txt"
    gold_audio_R_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    # --------------------------------------------------------------------------
    # Compare data
    # --------------------------------------------------------------------------
    print("--- Comparing golden data with testbench results")

    # Shift loaded file-data to compensate shift to testbench-data
    # TODO: why is this necessary?
    move_n_right(gold_pilot_fp, 25, fp_width_c, fp_width_frac_c)
    move_n_right(gold_carrier_38k_fp, 25, fp_width_c, fp_width_frac_c)
    move_n_left(gold_audio_mono_fp, 13, fp_width_c, fp_width_frac_c)
    move_n_left(gold_audio_lrdiff_fp, 13, fp_width_c, fp_width_frac_c)
    move_n_left(gold_audio_L_fp, 13, fp_width_c, fp_width_frac_c)
    move_n_left(gold_audio_R_fp, 13, fp_width_c, fp_width_frac_c)

    # Compare
    ok_fm_demod = compareResultsOkay(gold_fm_demod_fp,
                                     from_fixed_point(data_out_fm_demod_fp),
                                     fail_on_err=EnableFailOnError,
                                     max_error_abs=2**-5,
                                     max_error_norm=0.06,
                                     skip_n_samples_begin=30,
                                     skip_n_samples_end=30,
                                     data_name="fm_demod",
                                     is_cocotb=False)

    ok_audio_mono = compareResultsOkay(gold_audio_mono_fp,
                                       from_fixed_point(data_out_audio_mono_fp),
                                       fail_on_err=EnableFailOnError,
                                       max_error_abs=2**-5,
                                       max_error_norm=0.6,
                                       skip_n_samples_begin=100,
                                       skip_n_samples_end=100,
                                       data_name="audio_mono",
                                       is_cocotb=False)

    ok_pilot = compareResultsOkay(gold_pilot_fp,
                                  from_fixed_point(data_out_pilot_fp),
                                  fail_on_err=EnableFailOnError,
                                  max_error_abs=0.5,
                                  max_error_norm=3.0,
                                  skip_n_samples_begin=100,
                                  skip_n_samples_end=100,
                                  data_name="pilot",
                                  is_cocotb=False)

    ok_carrier_38k = compareResultsOkay(gold_carrier_38k_fp,
                                        from_fixed_point(data_out_carrier_38k_fp),
                                        fail_on_err=EnableFailOnError,
                                        max_error_abs=0.7,
                                        max_error_norm=7.0,
                                        skip_n_samples_begin=100,
                                        skip_n_samples_end=100,
                                        data_name="carrier_38k",
                                        is_cocotb=False)

    ok_audio_lrdiff = compareResultsOkay(gold_audio_lrdiff_fp,
                                         from_fixed_point(data_out_audio_lrdiff_fp),
                                         fail_on_err=EnableFailOnError,
                                         max_error_abs=2**-3,
                                         max_error_norm=0.9,
                                         skip_n_samples_begin=100,
                                         skip_n_samples_end=100,
                                         data_name="audio_lrdiff",
                                         is_cocotb=False)

    ok_audio_L = compareResultsOkay(gold_audio_L_fp,
                                    from_fixed_point(data_out_audio_L_fp),
                                    fail_on_err=EnableFailOnError,
                                    max_error_abs=2**-3,
                                    max_error_norm=0.9,
                                    skip_n_samples_begin=100,
                                    skip_n_samples_end=100,
                                    data_name="audio_L",
                                    is_cocotb=False)

    ok_audio_R = compareResultsOkay(gold_audio_R_fp,
                                    from_fixed_point(data_out_audio_R_fp),
                                    fail_on_err=EnableFailOnError,
                                    max_error_abs=2**-3,
                                    max_error_norm=0.9,
                                    skip_n_samples_begin=100,
                                    skip_n_samples_end=100,
                                    data_name="audio_R",
                                    is_cocotb=False)

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------
    print("--- Plots")

    # TODO: Enable plots for debug
    #ok_fm_demod = False
    #ok_audio_mono = False
    #ok_pilot = False
    #ok_carrier_38k = False
    #ok_audio_lrdiff = False
    #ok_audio_L = False
    #ok_audio_R = False

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
        (tn, from_fixed_point(data_out_carrier_38k_fp), "data_out_carrier_38k"),
        (tn, from_fixed_point(gold_carrier_38k_fp), "gold_carrier_38k")
    )
    plotData(data, title="Carrier 38kHz",
             filename="../tb/output/plot_carrier_38k.png",
             show=not ok_carrier_38k)
    # -----------------------------------------------------------------
    data = (
        (tn, from_fixed_point(data_out_audio_lrdiff_fp), "data_out_audio_lrdiff"),
        (tn, from_fixed_point(gold_audio_lrdiff_fp), "gold_audio_lrdiff")
    )
    plotData(data, title="Audio LR diff",
             filename="../tb/output/plot_audio_lrdiff.png",
             show=not ok_audio_lrdiff)
    # -----------------------------------------------------------------
    data = (
        (tn, from_fixed_point(data_out_audio_L_fp), "data_out_audio_L"),
        (tn, from_fixed_point(gold_audio_L_fp), "gold_audio_L")
    )
    plotData(data, title="Audio L",
             filename="../tb/output/plot_audio_L.png",
             show=not ok_audio_L)

    # -----------------------------------------------------------------
    data = (
        (tn, from_fixed_point(data_out_audio_R_fp), "data_out_audio_R"),
        (tn, from_fixed_point(gold_audio_R_fp), "gold_audio_R")
    )
    plotData(data, title="Audio R",
             filename="../tb/output/plot_audio_R.png",
             show=not ok_audio_R)


if __name__ == "__main__":
    analyze()
