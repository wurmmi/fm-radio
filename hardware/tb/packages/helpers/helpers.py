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


def plotData(data, title="", filename="", block=True):
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
    plt.show(block=block)


def compareResultsOkay(gold, actual, abs_max_error, skip_n_samples, data_name):
    """
    Compares actual data against "golden data".
    Metrics: number of samples,
    """

    # Sanity check
    if len(actual) < len(gold):
        msg = "Did not capture enough output values for '{}': {} actual, {} expected.".format(
            data_name, len(actual), len(gold))
        #raise cocotb.result.TestFailure(msg)
        cocotb.log.warning(msg)
        return False

    # Skip first N samples
    gold = gold[skip_n_samples:]
    actual = actual[skip_n_samples:]

    # Compute 2-Norm
    norm_res = np.linalg.norm(
        np.array(from_fixed_point(gold)) - np.array(actual), 2)
    cocotb.log.info("2-Norm for '{}': {}".format(data_name, norm_res))

    # Compare absolute difference
    for i in range(0, len(actual)):
        diff = gold[i] - actual[i]
        if abs(from_fixed_point(diff)) > abs_max_error:
            msg = "Actual value [idx={}] is not matching the expected value! Errors: {:.5f} > {}.".format(
                i, abs(from_fixed_point(diff)), abs_max_error)
            #raise cocotb.result.TestFailure(msg)
            cocotb.log.warning(msg)
            return False

    return True
