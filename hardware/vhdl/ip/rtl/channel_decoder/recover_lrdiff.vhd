-------------------------------------------------------------------------------
--! @file      recover_lrdiff.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Recover LR Diff implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_global_spec_pkg.all;
use work.fm_radio_pkg.all;
use work.filter_lp_mono_pkg.all;
use work.filter_bp_lrdiff_pkg.all;

entity recover_lrdiff is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i            : in sample_t;
    sample_valid_i      : in std_ulogic;
    carrier_38k_i       : in sample_t;
    carrier_38k_valid_i : in std_ulogic;

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

  signal lrdiff_mod_bb       : sample_t;
  signal lrdiff_mod_bb_valid : std_ulogic;

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal lrdiff_bpfilt       : sample_t;
  signal lrdiff_bpfilt_valid : std_ulogic;

  signal lrdiff       : sample_t;
  signal lrdiff_valid : std_ulogic;

  signal lrdiff_decimated       : sample_t;
  signal lrdiff_decimated_valid : std_ulogic;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  lrdiff_o       <= lrdiff_decimated;
  lrdiff_valid_o <= lrdiff_decimated_valid;

  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
      lrdiff_mod_bb       <= (others => '0');
      lrdiff_mod_bb_valid <= '0';
    end procedure reset;
  begin -- process regs
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
        -- Defaults
        lrdiff_mod_bb_valid <= '0';

        -- Modulate down to baseband
        -- TODO: check when carier_38k_i is valid, or store it here internally
        if lrdiff_bpfilt_valid = '1' then
          lrdiff_mod_bb <= ResizeTruncAbsVal(
            lrdiff_bpfilt * carrier_38k_i * to_sfixed(2, 2, 0), lrdiff_mod_bb);

          lrdiff_mod_bb_valid <= '1';
        end if;
      end if;
    end if;
  end process regs;

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  -- Bandpass 23..38kHz
  dspfir_bp_lrdiff_inst : entity work.DspFir
    generic map(
      gB => filter_bp_lrdiff_coeffs_c)
    port map(
      iClk        => clk_i,
      iResetAsync => rst_i,

      iDdry   => sample_i,
      iValDry => sample_valid_i,

      oDwet   => lrdiff_bpfilt,
      oValWet => lrdiff_bpfilt_valid);

  -- Lowpass 15kHz
  dspfir_lp_mono_inst : entity work.DspFir
    generic map(
      gB => filter_lp_mono_coeffs_c)
    port map(
      iClk        => clk_i,
      iResetAsync => rst_i,

      iDdry   => lrdiff_mod_bb,
      iValDry => lrdiff_mod_bb_valid,

      oDwet   => lrdiff,
      oValWet => lrdiff_valid);

  decimator_inst : entity work.decimator
    generic map(
      decimation_g => osr_audio_spec_c)
    port map(
      clk_i => clk_i,
      rst_i => rst_i,

      sample_i       => lrdiff,
      sample_valid_i => lrdiff_valid,

      sample_o       => lrdiff_decimated,
      sample_valid_o => lrdiff_decimated_valid);

end architecture rtl;
