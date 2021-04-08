################################################################################
# File        : analyze_tb_results.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Analyze data output of HLS testbench.
################################################################################


from fixed_point import *
from fm_global import *
from fm_receiver_model import FM_RECEIVER_MODEL
from helpers import *
from tb_analyzer_helper import TB_ANALYZER_HELPER

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
    num_samples_audio_c = len(data_out_audio_mono_fp)
    num_samples_c = len(data_out_pilot_fp)
    num_samples_fs_c = len(data_out_fm_demod_fp)

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

    tb_analyzer_helper = TB_ANALYZER_HELPER(
        num_samples_audio_c, num_samples_c, num_samples_fs_c)

    tb_data = [
        {
            'name': "fm_demod",
            'data': data_out_fm_demod_fp,
            'fs': fs_c
        },
        {
            'name': "audio_mono",
            'data': data_out_audio_mono_fp,
            'fs': fs_audio_c
        },
        {
            'name': "pilot",
            'data': data_out_pilot_fp,
            'fs': fs_rx_c
        },
        {
            'name': "carrier_38k",
            'data': data_out_carrier_38k_fp,
            'fs': fs_rx_c
        },
        {
            'name': "audio_lrdiff",
            'data': data_out_audio_lrdiff_fp,
            'fs': fs_audio_c
        },
        {
            'name': "audio_L",
            'data': data_out_audio_L_fp,
            'fs': fs_audio_c
        },
        {
            'name': "audio_R",
            'data': data_out_audio_R_fp,
            'fs': fs_audio_c
        }
    ]

    tb_analyzer_helper.compare_data(model, tb_data)

    # --------------------------------------------------------------------------
    # Plots
    # --------------------------------------------------------------------------
    print("--- Plots")
    tb_analyzer_helper.generate_plots(model, tb_data)


if __name__ == "__main__":
    analyze()
