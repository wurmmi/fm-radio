-------------------------------------------------------------------------------
--! @file      fm_receiver.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Receiver IP implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_pkg.all;

entity fm_receiver is
  generic (
    compile_ifft_ip_core_g : boolean := true);
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    read_strobe_i    : in  std_ulogic;
    read_data_real_o : out iq_value_t;
    read_data_imag_o : out iq_value_t);

end entity fm_receiver;

architecture rtl of fm_receiver is

  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{


  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal mod_symbol_re    : sample_t;
  signal mod_symbol_im    : sample_t;

  signal fft_source_real  : iq_value_t;
  signal fft_source_imag  : iq_value_t;

  signal fifo_read_strobe : std_ulogic;

  --! @}

begin  -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------


  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
    end procedure reset;
  begin  -- process regs
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
      end if;
    end if;
  end process regs;

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Assertions for testbench
  -----------------------------------------------------------------------------

  asserts : process (all)
  begin
    if NOW > 0 ns then -- to skip the meta values at the beginning

    end if;
  end process asserts;

end architecture rtl;
