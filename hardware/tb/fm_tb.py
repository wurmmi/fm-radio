################################################################################
# File        : ofdm_tb.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Testbench and Model of the gain ip
################################################################################

import cocotb
from cocotb.binary import BinaryRepresentation, BinaryValue
from cocotb.drivers import BitDriver
from cocotb.drivers.avalon import AvalonSTPkts as AvalonSTDriver
from cocotb.generators.byte import get_bytes, incrementing_data
from cocotb.monitors.avalon import AvalonSTPkts as AvalonSTMonitor
from cocotb.triggers import FallingEdge, RisingEdge, Timer

from fm_receiver_model import FM_RECEIVER_MODEL


class FM_TB(object):
    # Constants
    CLOCK_FREQ_MHZ = 80

    def __del__(self):
        self.fd.close()

    def __init__(self, dut: cocotb.handle.HierarchyObject):
        self.dut = dut
        self.dut._log.debug("Building/Connecting Testbench")
        self.fm_receiver_model = FM_RECEIVER_MODEL()

    @cocotb.coroutine
    async def reset(self):
        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)

        self.dut.rst_i <= 1
        await Timer(3.3, units="us")
        self.dut.rst_i <= 0
        await RisingEdge(self.dut.clk_i)
