################################################################################
# File        : test.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testcases for the FM Receiver IP.
################################################################################

import cocotb
import matplotlib.pyplot as plt
import numpy as np
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.generators import repeat
from cocotb.generators.bit import bit_toggler
from cocotb.triggers import RisingEdge, Timer

from fm_tb import FM_TB


@cocotb.test()
def fir_filter_test(dut):
    """Test data generator and writes data to files."""

    # Insantiate testbench
    tb = FM_TB(dut)

    # Generate clock
    clk_80mhz = Clock(dut.clk_i, period=1 / tb.CLOCK_FREQ_MHZ * 1000, units='ns')
    clk_gen = cocotb.fork(clk_80mhz.start())

    # Reset the DUT before any tests begin
    yield tb.reset()

    yield Timer(5, units='us')
