-------------------------------------------------------------------------------
--! @file      channel_decoder.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Channel Decoder implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_pkg.all;

entity channel_decoder is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i       : in sample_t;
    sample_valid_i : in std_ulogic;

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

  signal audio_mono       : sample_t;
  signal audio_mono_valid : std_ulogic;

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

  recover_mono_inst : entity work.recover_mono
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      sample_i       => sample_i,
      sample_valid_i => sample_valid_i,

      mono_o       => audio_mono,
      mono_valid_o => audio_mono_valid);

  -- RecoverLRDiff
  -- RecoverCarriers
  -- RecoverMono
  -- LRSeparator

end architecture rtl;
