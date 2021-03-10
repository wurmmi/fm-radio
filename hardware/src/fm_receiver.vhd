-------------------------------------------------------------------------------
--! @file      fm_receiver.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Receiver IP implementation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TIME LOGGING
--
-- (1) FIR Filter implementation
--    03/10/2021 11:30 - xx:xx    2:00 h
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_pkg.all;
use work.filter_bp_pilot_pkg.all;

entity fm_receiver is
  generic (
    compile_ifft_ip_core_g : boolean := true);
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    fir_i       : in  sample_t;
    fir_valid_i : in  std_ulogic;
    fir_o       : out sample_t;
    fir_valid_o : out std_ulogic;

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

  dspfir_inst : entity work.DspFir
  generic map(
      gB => filter_bp_pilot_coeffs_c)
  port map(
      iClk            => clk_i,
      inResetAsync    => not rst_i,
      iDdry           => fir_i,
      iValDry         => fir_valid_i,
      oDwet           => fir_o,
      oValWet         => fir_valid_o);

  -----------------------------------------------------------------------------
  -- Assertions for testbench
  -----------------------------------------------------------------------------

  asserts : process (all)
  begin
    if NOW > 0 ns then -- to skip the meta values at the beginning

    end if;
  end process asserts;

end architecture rtl;
