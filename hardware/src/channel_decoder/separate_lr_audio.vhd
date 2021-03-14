-------------------------------------------------------------------------------
--! @file      separate_lr_audio.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Separate LR audio implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_pkg.all;

entity separate_lr_audio is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    mono_i         : in  sample_t;
    mono_valid_i   : in  std_ulogic;
    lrdiff_i       : in  sample_t;
    lrdiff_valid_i : in  std_ulogic;

    audio_L_o     : out sample_t;
    audio_R_o     : out sample_t;
    audio_valid_o : out std_ulogic);

end entity separate_lr_audio;

architecture rtl of separate_lr_audio is

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

  -- LPFilter 15k
  -- Delay

end architecture rtl;
