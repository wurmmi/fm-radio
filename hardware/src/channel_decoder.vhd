-------------------------------------------------------------------------------
--! @file      channel_decoder.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Channel Decoder implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_pkg.all;

entity channel_decoder is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i       : in  sample_t;
    sample_valid_i : in  std_ulogic;

    audio_L_o     : out sample_t;
    audio_R_o     : out sample_t;
    audio_valid_o : out std_ulogic);

end entity channel_decoder;

architecture rtl of channel_decoder is

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

  -- RecoverLRDiff
  -- RecoverCarriers
  -- RecoverMono
  -- LRSeparator

end architecture rtl;
