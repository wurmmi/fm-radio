-------------------------------------------------------------------------------
--! @file      recover_mono.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Recover Mono implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_pkg.all;
use work.filter_bp_pilot_pkg.all;

entity recover_mono is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i       : in  sample_t;
    sample_valid_i : in  std_ulogic;

    mono_o       : out sample_t;
    mono_valid_o : out std_ulogic);

end entity recover_mono;

architecture rtl of recover_mono is

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


  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  dspfir_lp_mono_inst : entity work.DspFir
  generic map(
      gB => filter_bp_mono_coeffs_c)
  port map(
      iClk            => clk_i,
      inResetAsync    => not rst_i,
      iDdry           => fir_i,
      iValDry         => fir_valid_i,
      oDwet           => fir_o,
      oValWet         => fir_valid_o);

  -- Delay

end architecture rtl;
