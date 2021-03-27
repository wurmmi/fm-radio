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
--       03/10/2021  11:30 - 14:00    2:30 h
--                   15:15 - 19:15    4:00 h
--
-- (2) FM receiver implementation
--       03/14/2021  09:30 - 12:00    2:30 h
--                   12:30 - 14:00    1:30 h
--       03/15/2021  09:00 - 12:30    3:30 h
--                   13:00 - 17:00    5:00 h
--       03/16/2021  09:30 - 12:30    3:00 h
--                   13:00 - 18:00    5:00 h
--       03/17/2021  09:00 - 12:30    3:30 h
--                   14:00 - 18:00    4:00 h
--       03/18/2021  09:00 - 14:00    5:00 h
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_global_pkg.all;

entity fm_receiver is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    i_sample_i : in iq_value_t;
    q_sample_i : in iq_value_t;
    iq_valid_i : in std_ulogic;

    audio_L_o     : out sample_t;
    audio_R_o     : out sample_t;
    audio_valid_o : out std_ulogic);

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

  signal fm_demod       : sample_t;
  signal fm_demod_valid : std_ulogic;

  signal fm_channel_data       : sample_t;
  signal fm_channel_data_valid : std_ulogic;

  signal audio_L     : sample_t;
  signal audio_R     : sample_t;
  signal audio_valid : std_ulogic;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  audio_L_o     <= audio_L;
  audio_R_o     <= audio_R;
  audio_valid_o <= audio_valid;

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  fm_demodulator_inst : entity work.fm_demodulator
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      i_sample_i => i_sample_i,
      q_sample_i => q_sample_i,
      iq_valid_i => iq_valid_i,

      fm_demod_o       => fm_demod,
      fm_demod_valid_o => fm_demod_valid);

  decimator_inst : entity work.decimator
    generic map(
      decimation_g => osr_rx_c)
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      sample_i       => fm_demod,
      sample_valid_i => fm_demod_valid,

      sample_o       => fm_channel_data,
      sample_valid_o => fm_channel_data_valid);

  channel_decoder_inst : entity work.channel_decoder
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      sample_i       => fm_channel_data,
      sample_valid_i => fm_channel_data_valid,

      audio_L_o     => audio_L,
      audio_R_o     => audio_R,
      audio_valid_o => audio_valid);

  -----------------------------------------------------------------------------
  -- Assertions for testbench
  -----------------------------------------------------------------------------

  asserts : process (all)
  begin
    if NOW > 0 ns then -- to skip the meta values at the beginning

    end if;
  end process asserts;

end architecture rtl;
