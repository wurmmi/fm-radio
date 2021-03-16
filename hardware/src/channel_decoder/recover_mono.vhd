-------------------------------------------------------------------------------
--! @file      recover_mono.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Recover Mono implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_pkg.all;
use work.filter_lp_mono_pkg.all;

entity recover_mono is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i       : in sample_t;
    sample_valid_i : in std_ulogic;

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

  signal mono       : sample_t;
  signal mono_valid : std_ulogic;

  signal mono_delayed       : sample_t;
  signal mono_valid_delayed : std_ulogic;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  mono_o       <= mono_delayed;
  mono_valid_o <= mono_valid_delayed;

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
      gB => filter_lp_mono_coeffs_c)
    port map(
      iClk         => clk_i,
      inResetAsync => not rst_i,

      iDdry   => sample_i,
      iValDry => sample_valid_i,

      oDwet   => mono,
      oValWet => mono_valid);

  delay_vector_inst : entity work.delay_vector
    generic map(
      gDelay => filter_lp_mono_grpdelay_c + 2)
    port map(
      iClk         => clk_i,
      inResetAsync => not rst_i,

      iDdry   => mono,
      iValDry => mono_valid,

      oDwet   => mono_delayed,
      oValWet => mono_valid_delayed);

end architecture rtl;
