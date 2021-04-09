################################################################################
# File        : analyze_tb_results.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Analyze data output of HLS testbench.
################################################################################


from fm_global import *
from fm_receiver_model import FM_RECEIVER_MODEL
from tb_analyzer_helper import TB_ANALYZER_HELPER
from tb_data_result_loader import TB_DATA_RESULT_LOADER

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
    tb_result_loader = TB_DATA_RESULT_LOADER()
    tb_result_loader.load_data_from_file(directory_tb)

    # Check number of samples that were found in the files
    # NOTE: Make sure to use correct indexes, according to TB_DATA_RESULT_LOADER
    num_samples_audio_c = len(tb_result_loader.data[1]['data'])  # audio_mono
    num_samples_c = len(tb_result_loader.data[2]['data'])        # pilot
    num_samples_fs_c = len(tb_result_loader.data[0]['data'])     # fm_demod

    # Sanity checks
    assert num_samples_fs_c // num_samples_c == osr_rx_c, \
        "File lengths don't match osr_rx_c ..."
    assert num_samples_c // num_samples_audio_c == osr_audio_c, \
        "File lengths don't match osr_audio_c ..."

    n_sec = num_samples_c / fs_rx_c
    print(f"Loaded {n_sec} seconds worth of data!")

    # Golden data
    print("- Golden output data")

    golden_data_directory = "../../../sim/matlab/verification_data/"
    model = FM_RECEIVER_MODEL(n_sec, golden_data_directory, is_cocotb=False)

    # --------------------------------------------------------------------------
    # Compare data
    # --------------------------------------------------------------------------
    print("--- Comparing golden data with testbench results")

    tb_analyzer_helper = TB_ANALYZER_HELPER(model, tb_result_loader, is_cocotb=False)
    tb_analyzer_helper.compare_data()

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------
    print("--- Plots")

    directory_plot_output = "../tb/output"
    tb_analyzer_helper.generate_plots(directory_plot_output)


if __name__ == "__main__":
    analyze()
