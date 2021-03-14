-------------------------------------------------------------------------------
--! @file      fm_receiver.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Receiver IP implementation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TIME LOGGING
--
-- (1) FIR filter implementation
--    03/10/2021  11:30 - 14:00    2:30 h
--                15:15 - 19:15    4:00 h
-- (2) FM receiver implementation
--    03/14/2021  09:30 - xx:xx    x:xx h
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

    i_sample_i     : in  iq_value_t;
    q_sample_i     : in  iq_value_t;
    sample_valid_i : in  std_ulogic;

    audio_L_o     : out sample_t;
    audio_R_o     : out sample_t;
    audio_valid_o : out std_ulogic;

    -- testing only
    fir_i       : in  sample_t;
    fir_valid_i : in  std_ulogic;
    fir_o       : out sample_t;
    fir_valid_o : out std_ulogic);

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
