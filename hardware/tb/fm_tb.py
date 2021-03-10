################################################################################
# File        : fm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench and Model of the gain ip
################################################################################

import cocotb
from cocotb.triggers import RisingEdge, Timer
from fixed_point import *

from fm_receiver_model import FM_RECEIVER_MODEL


class FM_TB(object):
    # Constants
    CLOCK_FREQ_MHZ = 48
    FS_RX_KHZ = 120

    # Variables
    data_out = []

    assert (CLOCK_FREQ_MHZ * 1e3 / FS_RX_KHZ).is_integer(), \
        "Clock rate and fs_rx must have an integer relation!"

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject, fp_width, fp_width_frac, num_samples):
        self.dut = dut
        self.dut._log.debug("Building/Connecting Testbench")
        self.fm_receiver_model = FM_RECEIVER_MODEL()
        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac
        self.num_samples_c = num_samples

    @cocotb.coroutine
    async def reset(self):
        self.dut._log.info("Resetting DUT ...")

        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)
        self.dut.rst_i <= 1
        await Timer(3.3, units="us")
        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)

    @cocotb.coroutine
    async def assign_defaults(self):
        self.dut._log.info("Setting defaults ...")

        self.dut.fir_valid_i <= 0

    @cocotb.coroutine
    async def read_fir_result(self):
        edge = RisingEdge(self.dut.fir_valid_o)
        while(True):
            await edge
            sample_out = self.dut.fir_o.value.signed_integer * 11
            self.data_out.append(
                int_to_fixed(sample_out, self.fp_width_c, self.fp_width_frac_c))
            size = len(self.data_out)
            print(size)
            # if size >= self.num_samples_c:
            #    return
