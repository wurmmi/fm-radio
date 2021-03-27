-------------------------------------------------------------------------------
--! @file      fm_receiver_top.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Receiver Top-level implementation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TIME LOGGING
--
-- (1) FM receiver top (interface) implementation
--       03/27/2021  15:30 - xxxxx    5:00 h
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_global_pkg.all;

entity fm_receiver_top is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    i_sample_i : in iq_value_t;
    q_sample_i : in iq_value_t;
    iq_valid_i : in std_ulogic;

    audio_L_o     : out sample_t;
    audio_R_o     : out sample_t;
    audio_valid_o : out std_ulogic);

end entity fm_receiver_top;

architecture rtl of fm_receiver_top is

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
  signal req_sample  : std_ulogic;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  audio_L_o     <= audio_L;
  audio_R_o     <= audio_R;
  audio_valid_o <= audio_valid;
  req_sample_o  <= req_sample;

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  strobe_gen_inst : entity work.strobe_gen
    generic map(
      clk_freq_g => clk_freq_system_c,
      period_g   => (1 sec / fs_c))
    port map(
      clk_i   => clk_i,
      rst_n_i => rst_i,

      enable_i => '1',
      strobe_o => req_sample);

  -- FM receiver IP
  fm_receiver_inst : entity work.fm_receiver
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      i_sample_i => i_sample_i,
      q_sample_i => q_sample_i,
      iq_valid_i => iq_valid_i,

      audio_L_o     => audio_L,
      audio_R_o     => audio_R,
      audio_valid_o => audio_valid);

end architecture rtl;
