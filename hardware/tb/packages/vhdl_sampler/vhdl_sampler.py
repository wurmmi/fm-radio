################################################################################
# File        : vhdl_sampler.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Sampler - samples data from VHDL.
################################################################################

import cocotb
from cocotb.triggers import RisingEdge
from fixed_point import *
from helpers import *


class VHDL_SAMPLER(object):
    def __del__(self):
        pass

    def __init__(self, data_name, dut: cocotb.handle.HierarchyObject,
                 signal: cocotb.handle.RealObject,
                 signal_valid: cocotb.handle.RealObject,
                 num_expected,
                 fp_width, fp_width_frac):
        self.data_name = data_name
        self.dut = dut
        self._signal = signal
        self._signal_valid = signal_valid
        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac
        self.num_expected = num_expected

    @cocotb.coroutine
    async def read_vhdl_output(self, data):
        while(True):
            await RisingEdge(self._signal_valid)
            data.append(
                int_to_fixed(self._signal.value.signed_integer, self.fp_width_c, self.fp_width_frac_c))

            # print every 100th number to show progress
            size = len(data)
            if size % 100 == 0:
                self.dut._log.info("Progress {}: {}".format(self.data_name, size))

            if size >= self.num_expected:
                break
