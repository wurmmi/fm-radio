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
use ieee.fixed_pkg.all;

library work;
use work.fm_global_pkg.all;

entity fm_receiver_top is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    -- AXI Stream input
    S00_axis_tready : out std_ulogic;
    S00_axis_tdata  : in std_ulogic_vector(31 downto 0);
    S00_axis_tvalid : in std_ulogic;

    -- Output
    audio_L_o     : out sample_t;
    audio_R_o     : out sample_t;
    audio_valid_o : out std_ulogic);

end entity fm_receiver_top;

architecture rtl of fm_receiver_top is

  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal req_sample : std_ulogic;

  signal i_sample : sample_t;
  signal q_sample : sample_t;

  signal audio_L     : sample_t;
  signal audio_R     : sample_t;
  signal audio_valid : std_ulogic;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  S00_axis_tready <= req_sample;

  audio_L_o     <= audio_L;
  audio_R_o     <= audio_R;
  audio_valid_o <= audio_valid;

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  i_sample <= to_sfixed(S00_axis_tdata(15 downto 0), i_sample);
  q_sample <= to_sfixed(S00_axis_tdata(31 downto 16), q_sample);

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  -- Strobe generator to request samples at the required sample rate
  strobe_gen_inst : entity work.strobe_gen
    generic map(
      clk_freq_g => clk_freq_system_c,
      period_g   => (1 sec / fs_c))
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      enable_i => '1',
      strobe_o => req_sample);

  -- FM receiver IP
  fm_receiver_inst : entity work.fm_receiver
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      i_sample_i => i_sample,
      q_sample_i => q_sample,
      iq_valid_i => S00_axis_tvalid,

      audio_L_o     => audio_L,
      audio_R_o     => audio_R,
      audio_valid_o => audio_valid);

end architecture rtl;
