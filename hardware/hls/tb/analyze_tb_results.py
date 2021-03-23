################################################################################
# File        : analyze_tb_results.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Analyze data output of HLS testbench.
################################################################################


#from fixed_point import *
from helpers import *

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------
# Number of seconds to process
n_sec = 0.001  # TODO: get this from file
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

    filename = directory_gold + "rx_pilot.txt"
    gold_pilot_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_gold + "rx_fm_demod.txt"
    gold_fm_demod_fp = loadDataFromFile(filename, num_samples_fs_c, fp_width_c, fp_width_frac_c)

    # Testbench result data
    directory_tb = "../tb/output/"
    filename = directory_tb + "data_out_rx_pilot.txt"
    data_out_pilot_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    filename = directory_tb + "data_out_fm_demod.txt"
    data_out_fm_demod_fp = loadDataFromFile(filename, num_samples_fs_c, fp_width_c, fp_width_frac_c)

    # --------------------------------------------------------------------------
    # Compare data
    # --------------------------------------------------------------------------
    ok_fm_demod = compareResultsOkay(gold_fm_demod_fp,
                                     from_fixed_point(data_out_fm_demod_fp),
                                     fail_on_err=EnableFailOnError,
                                     max_error_abs=2**-5,
                                     max_error_norm=0.002,
                                     skip_n_samples=30,
                                     data_name="fm_demod",
                                     is_cocotb=False)

    ok_pilot = compareResultsOkay(gold_pilot_fp,
                                  from_fixed_point(data_out_pilot_fp),
                                  fail_on_err=EnableFailOnError,
                                  max_error_abs=2**-5,
                                  max_error_norm=0.6,
                                  skip_n_samples=30,
                                  data_name="pilot",
                                  is_cocotb=False)

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------

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
        (tn, from_fixed_point(data_out_pilot_fp), "data_out_pilot"),
        (tn, from_fixed_point(gold_pilot_fp), "gold_pilot")
    )
    plotData(data, title="Pilot",
             filename="../tb/output/plot_pilot.png",
             show=True)


if __name__ == "__main__":
    analyze()
