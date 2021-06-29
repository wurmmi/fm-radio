################################################################################
# File        : vhdl_sampler.py
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Sampler - samples data from VHDL.
################################################################################


import cocotb
from cocotb.triggers import RisingEdge
from fixed_point import int_to_fixed


class VHDL_SAMPLER():
    def __del__(self):
        pass

    def __init__(self, data_name, dut: cocotb.handle.HierarchyObject,
                 signal,
                 signal_valid,
                 num_expected,
                 fp_width, fp_width_frac, show_progress_after_num=100):
        self.data_name = data_name
        self.dut = dut
        self.signal = signal
        self.signal_valid = signal_valid
        self.fp_width_c = fp_width
        self.fp_width_frac_c = fp_width_frac
        self.num_expected_c = num_expected
        self.show_progress_after_num_c = show_progress_after_num

    @cocotb.coroutine
    async def read_vhdl_output(self, data):
        while(True):
            await RisingEdge(self.signal_valid)
            data.append(
                int_to_fixed(self.signal.value.signed_integer, self.fp_width_c, self.fp_width_frac_c))

            # print every Nth number to show progress
            size = len(data)
            if size % self.show_progress_after_num_c == 0:
                self.dut._log.info("Progress {:15s}: {:4d}/{:4d}".format(self.data_name, size, self.num_expected_c))

            if size >= self.num_expected_c:
                self.dut._log.info(
                    "---> {} received all samples".format(self.data_name))
                break

    @cocotb.coroutine
    async def read_vhdl_output_32bit_split(self, data_L, data_R):
        while(True):
            await RisingEdge(self.signal_valid)
            left = self.signal.value[0:15].signed_integer
            right = self.signal.value[16:31].signed_integer
            data_L.append(int_to_fixed(left, self.fp_width_c, self.fp_width_frac_c))
            data_R.append(int_to_fixed(right, self.fp_width_c, self.fp_width_frac_c))

            # print every Nth number to show progress
            size = len(data_L)
            if size % self.show_progress_after_num_c == 0:
                self.dut._log.info("Progress {:15s}: {:4d}/{:4d}".format(self.data_name, size, self.num_expected_c))

            if size >= self.num_expected_c:
                self.dut._log.info(
                    "---> {} received all samples".format(self.data_name))
                break
