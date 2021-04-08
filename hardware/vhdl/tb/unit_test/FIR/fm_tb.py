################################################################################
# File        : fm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench and Model of the gain ip
################################################################################

import cocotb
from cocotb.drivers import BitDriver
from cocotb.triggers import RisingEdge, Timer
from fixed_point import *


class FM_TB(object):
    # Constants
    CLOCK_FREQ_MHZ = 48
    FS_RX_KHZ = 120

    # Variables
    data_out = []

    assert (CLOCK_FREQ_MHZ * 1000 / FS_RX_KHZ).is_integer(), \
        "Clock rate and fs_rx_c must have an integer relation!"

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject, fp_width, fp_width_frac, num_samples):
        self.dut = dut
        self.dut._log.debug("Building/Connecting Testbench")

        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac
        self.num_samples_c = num_samples

        self.fir_in_strobe = BitDriver(self.dut.iValDry, self.dut.iClk)

    @cocotb.coroutine
    async def reset(self):
        self.dut._log.info("Resetting DUT ...")

        self.dut.inResetAsync <= 1
        await RisingEdge(self.dut.iClk)
        self.dut.inResetAsync <= 0
        await Timer(3.3, units='us')
        self.dut.inResetAsync <= 1
        await RisingEdge(self.dut.iClk)

    @cocotb.coroutine
    async def assign_defaults(self):
        self.dut._log.info("Setting input port defaults ...")

        #self.dut.iValDry <= 0
        self.dut.iDdry <= 0

    @cocotb.coroutine
    async def read_fir_result(self, output_scale):
        edge = RisingEdge(self.dut.oValWet)
        while(True):
            await edge
            sample_out = self.dut.oDwet.value.signed_integer * output_scale
            self.data_out.append(
                int_to_fixed(sample_out, self.fp_width_c, self.fp_width_frac_c))

            # print every 10th number to show progress
            size = len(self.data_out)
            if size % 10 == 0:
                self.dut._log.info("Progress sample: {}".format(size))
