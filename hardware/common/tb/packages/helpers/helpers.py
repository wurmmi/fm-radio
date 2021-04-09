################################################################################
# File        : helpers.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Library for common helper functions.
################################################################################

import cocotb
import matplotlib.pyplot as plt
import numpy as np
from fixed_point import from_fixed_point, to_fixed_point


def loadDataFromFile(filename, num_samples, bitwidth, bitwidth_frac, use_fixed=True):
    """
    Loads data from a file and converts it to fixed_point.
    Set num_samples to a negative value to load entire file.
    """
    data = []
    with open(filename) as fd:
        val_count = 0
        for line in fd:
            data.append(float(line.strip('\n')))
            val_count += 1
            # Stop after required number of samples
            if num_samples >= 0 and val_count >= num_samples:
                break

    if num_samples >= 0 and val_count < num_samples:
        raise cocotb.result.TestFailure(
            "File '{}' contains less elements than requested ({} < {}). Run Matlab to create more data!".format(
                filename, val_count, num_samples))
    if use_fixed:
        data = to_fixed_point(data, bitwidth, bitwidth_frac)
    return data


def get_dataset_by_name(datalist, data_name, log_func=cocotb.logging.error):
    # Find the dataset with the matching data_name
    dataset = [x for x in datalist if x['name'] == data_name]
    if len(dataset) == 0:
        log_func("Could not find dataset with name: '{}' !!".format(data_name))
    return dataset[0]['data']


def plotData(data, title="", filename="", show=True, block=True):
    """
    Plots data in a line diagram.\n
    Usage:  plotData((
                  (x1,y1,"data 1"),
                  (x2,y2,"data 2")),
                  title="My Diagram Title",
                  filename="sim_build/my_plot.png")
    """
    fig = plt.figure()
    for x, y, label in data:
        plt.plot(x, y, label=label)
    plt.title(title)
    plt.grid(True)
    plt.legend(loc='upper left')
    fig.tight_layout()
    plt.xlim([0, max(x)])

    if not (filename == ""):
        plt.savefig(filename, bbox_inches='tight')
        store_plot_pickle(fig, filename)
    if show:
        plt.show(block=block)
    plt.close()


def compareResultsOkay(gold, actual, fail_on_err,
                       max_error_abs, max_error_norm,
                       skip_n_samples_begin, skip_n_samples_end,
                       data_name="data_name", is_cocotb=True):
    """
    Compares actual data against "golden data".
    Metrics: number of samples,
    """
    # Adapt logging functions
    if is_cocotb:
        log_info = cocotb.logging.info
        log_warn = cocotb.logging.warning
        test_fail = cocotb.result.TestFailure
    else:
        log_info = print
        log_warn = print
        test_fail = Exception

    # Sanity check
    if len(actual) < len(gold):
        msg = "Did not capture enough output values for {}: {} actual, {} expected.".format(
            data_name, len(actual), len(gold))
        if fail_on_err:
            raise test_fail(msg)
        log_warn(msg)
        return True

    # Skip first and last N samples
    if skip_n_samples_end == 0:
        skip_n_samples_end = 1  # cannot index with -0 in next lines
    gold = gold[skip_n_samples_begin:-skip_n_samples_end]
    actual = actual[skip_n_samples_begin:-skip_n_samples_end]

    # Compute 2-Norm
    norm_res = np.linalg.norm(
        np.array(from_fixed_point(gold)) - np.array(actual), 2)
    if norm_res > max_error_norm:
        msg = "FAIL results for {:15s}: 2-Norm too large! {:.5f} > {}.".format(
            data_name, norm_res, max_error_norm)
        if fail_on_err:
            raise test_fail(msg)
        log_warn(msg)
        return False

    # Compare absolute error
    max_error_abs_found = 0
    for i in range(0, len(actual)):
        diff = gold[i] - actual[i]

        abs_err = abs(from_fixed_point(diff))
        max_error_abs_found = max(max_error_abs_found, abs_err)
        if abs_err > max_error_abs:
            msg = "FAIL results for {:15s}: Actual value [idx={}] is not matching the expected value! Errors: {:.5f} > {}.".format(
                data_name, i, abs_err, max_error_abs)
            if fail_on_err:
                raise test_fail(msg)
            log_warn(msg)
            return False

    log_info("OKAY results for {:15s}: 2-norm = {:.5f}, max_abs_err = {:.5f}".format(
        data_name, norm_res, max_error_abs_found))
    return True


def move_n_right(data, amount, fp_width, fp_width_frac):
    assert amount >= 0, "Amount must be a >=0 integer!!"
    for _ in range(0, amount):
        # insert at begin
        data.insert(0, to_fixed_point(0, fp_width, fp_width_frac))
        # remove end
        data.pop()


def move_n_left(data, amount, fp_width, fp_width_frac):
    assert amount >= 0, "Amount must be a >=0 integer!!"
    for _ in range(0, amount):
        # insert at end
        data.append(to_fixed_point(0, fp_width, fp_width_frac))
        # remove begin
        data.pop(0)


def store_plot_pickle(fig, filename):
    import pickle
    with open(filename + ".pickle", 'wb') as fd:
        pickle.dump(fig, fd)


def reload_plot_pickle(filename):
    import pickle
    with open(filename, 'rb') as fd:
        fig = pickle.load(fd)
        plt.show()


def reload_all_plots_pickle(directory):
    import os
    import pickle

    print(f"Loading all plots from directory '{directory}'...\n")

    filenames = []
    for file in os.listdir(directory):
        if file.endswith(".pickle"):
            filenames.append(os.path.join(directory, file))

    for filename in filenames:
        print(f"Opening plot {filename}")
        with open(filename, 'rb') as fd:
            fig = pickle.load(fd)
            if filename == filenames[-1]:
                plt.show(block=True)
            else:
                plt.show(block=False)
