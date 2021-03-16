################################################################################
# File        : helpers.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Library for common helper functions.
################################################################################

import cocotb
import matplotlib.pyplot as plt
import numpy as np
from fixed_point import from_fixed_point, to_fixed_point


def loadDataFromFile(filename, num_samples, bitwidth, bitwidth_frac):
    """
    Loads data from a file and converts it to fixed_point.
    """
    data = []
    with open(filename) as fd:
        val_count = 0
        for line in fd:
            data.append(float(line.strip('\n')))
            val_count += 1
            # Stop after required number of samples
            if val_count >= num_samples:
                break

    if val_count < num_samples:
        raise cocotb.result.TestFailure(
            "File '{}' contains less elements than requested ({} < {}).".format(
                filename, val_count, num_samples))

    data = to_fixed_point(data, bitwidth, bitwidth_frac)
    return data


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
    plt.legend()
    fig.tight_layout()
    plt.xlim([0, max(x)])

    if not (filename == ""):
        plt.savefig(filename, bbox_inches='tight')
    if show:
        plt.show(block=block)


def compareResultsOkay(dut, gold, actual, fail_on_err,
                       max_error_abs, max_error_norm,
                       skip_n_samples, data_name):
    """
    Compares actual data against "golden data".
    Metrics: number of samples,
    """

    # Sanity check
    if len(actual) < len(gold):
        msg = "Did not capture enough output values for '{}': {} actual, {} expected.".format(
            data_name, len(actual), len(gold))
        if fail_on_err:
            raise cocotb.result.TestFailure(msg)
        cocotb.log.warning(msg)
        return False

    # Skip first and last N samples
    gold = gold[skip_n_samples:-skip_n_samples]
    actual = actual[skip_n_samples:-skip_n_samples]

    # Compute 2-Norm
    norm_res = np.linalg.norm(
        np.array(from_fixed_point(gold)) - np.array(actual), 2)
    if norm_res > max_error_norm:
        msg = "2-Norm too large! {:.5f} > {}.".format(norm_res, max_error_norm)
        if fail_on_err:
            raise cocotb.result.TestFailure(msg)
        cocotb.log.warning(msg)
        return False

    # Compare absolute error
    for i in range(0, len(actual)):
        diff = gold[i] - actual[i]

        abs_err = abs(from_fixed_point(diff))
        if abs_err > max_error_abs:
            msg = "Actual value [idx={}] is not matching the expected value! Errors: {:.5f} > {}.".format(
                i, abs_err, max_error_abs)
            if fail_on_err:
                raise cocotb.result.TestFailure(msg)
            cocotb.log.warning(msg)
            return False

    dut._log.info("OKAY results for '{}' (2-norm = {:.5f})".format(
        data_name, norm_res))
    return True
