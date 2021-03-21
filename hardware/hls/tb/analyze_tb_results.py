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
n_sec = 0.001

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

    # Testbench result data
    directory_tb = "../tb/output/"
    filename = directory_tb + "data_out_rx_pilot.txt"
    data_out_pilot_fp = loadDataFromFile(filename, num_samples_c, fp_width_c, fp_width_frac_c)

    # --------------------------------------------------------------------------
    # Compare data
    # --------------------------------------------------------------------------

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------
    tn = np.arange(0, num_samples_c) / fs_rx_c

    data = (
        (tn, from_fixed_point(data_out_pilot_fp), "data_out_pilot"),
        (tn, from_fixed_point(gold_pilot_fp), "gold_pilot")
    )
    plotData(data, title="Pilot",
             filename="../tb/output/plot_pilot.png",
             show=True)


if __name__ == "__main__":
    analyze()
