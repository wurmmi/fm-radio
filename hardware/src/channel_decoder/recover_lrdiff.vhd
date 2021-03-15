-------------------------------------------------------------------------------
--! @file      recover_lrdiff.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Recover LR Diff implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_pkg.all;

entity recover_lrdiff is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i       : in sample_t;
    sample_valid_i : in std_ulogic;

    lrdiff_o       : out sample_t;
    lrdiff_valid_o : out std_ulogic);

end entity recover_lrdiff;

architecture rtl of recover_lrdiff is

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

begin -- architecture rtl

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

  -- BPFilter 23..53k
  -- (Delay) ?
  -- Mixer

end architecture rtl;
