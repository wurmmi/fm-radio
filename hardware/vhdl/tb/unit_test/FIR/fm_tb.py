################################################################################
# File        : fm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench and Model of the gain ip
################################################################################


import cocotb
import fm_global
from cocotb.triggers import RisingEdge, Timer
from cocotb_bus.drivers import BitDriver
from fixed_point import int_to_fixed


class FM_TB():
    # Constants
    CLOCK_FREQ_MHZ = 48

    # Variables
    data_out = []

    def __del__(self):
        pass

    def __init__(self, dut: cocotb.handle.HierarchyObject, num_samples):
        self.dut = dut
        self.dut._log.debug("Building/Connecting Testbench")

        # Sanity checks
        assert (self.CLOCK_FREQ_MHZ * 1e9 / fm_global.fs_rx_c).is_integer(), \
            "Clock rate and fs_rx_c must have an integer relation!"

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
    async def read_fir_result(self, output_scale, num_expected):
        edge = RisingEdge(self.dut.oValWet)
        while(True):
            await edge
            sample_out = self.dut.oDwet.value.signed_integer * output_scale
            self.data_out.append(
                int_to_fixed(sample_out, fm_global.fp_width_c, fm_global.fp_width_frac_c))

            # print every 10th number to show progress
            size = len(self.data_out)
            if size % 10 == 0:
                self.dut._log.info("Progress sample: {}".format(size))

            if size >= num_expected:
                break
