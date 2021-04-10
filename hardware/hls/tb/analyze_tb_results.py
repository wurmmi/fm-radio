################################################################################
# File        : analyze_tb_results.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Analyze data output of HLS testbench.
################################################################################


import helpers as helper
from fm_global import *
from fm_receiver_model import FM_RECEIVER_MODEL
from tb_analyzer_helper import TB_ANALYZER_HELPER
from tb_data_handler import TB_DATA_HANDLER

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
    print("- Testbench output data")

    directory_tb = "../tb/output/"
    tb_data_handler = TB_DATA_HANDLER()
    tb_data_handler.load_data_from_file(directory_tb)

    # Check number of samples that were found in the files
    num_samples_audio_c = len(helper.get_dataset_by_name(tb_data_handler.data, 'audio_mono'))
    num_samples_rx_c = len(helper.get_dataset_by_name(tb_data_handler.data, 'pilot'))
    num_samples_fs_c = len(helper.get_dataset_by_name(tb_data_handler.data, 'fm_demod'))

    # Sanity checks
    assert num_samples_fs_c // num_samples_rx_c == osr_rx_c, \
        "File lengths don't match osr_rx_c ..."
    assert num_samples_rx_c // num_samples_audio_c == osr_audio_c, \
        "File lengths don't match osr_audio_c ..."

    n_sec = num_samples_rx_c / fs_rx_c
    print(f"Loaded {n_sec} seconds worth of data!")

    # Golden data
    print("- Golden output data")

    golden_data_directory = "../../../sim/matlab/verification_data/"
    model = FM_RECEIVER_MODEL(n_sec, golden_data_directory, is_cocotb=False)

    # --------------------------------------------------------------------------
    # Compare results
    # --------------------------------------------------------------------------
    print("--- Comparing golden data with testbench results")

    tb_analyzer_helper = TB_ANALYZER_HELPER(model, tb_data_handler, is_cocotb=False)
    tb_analyzer_helper.compare_data()

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------
    print("--- Plots")

    directory_plot_output = "../tb/output"
    tb_analyzer_helper.generate_plots(directory_plot_output)


if __name__ == "__main__":
    analyze()
