-------------------------------------------------------------------------------
--! @file      fm_demodulator.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Demodulator implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_pkg.all;
use work.filter_diff_pkg.all;

entity fm_demodulator is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    i_sample_i : in iq_value_t;
    q_sample_i : in iq_value_t;
    iq_valid_i : in std_ulogic;

    fm_demod_o       : out sample_t;
    fm_demod_valid_o : out std_ulogic);

end entity fm_demodulator;

architecture rtl of fm_demodulator is

  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal demod_part_a : sample_t;
  signal demod_part_b : sample_t;

  signal fm_demod       : sample_t;
  signal fm_demod_valid : std_ulogic;

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal i_sample_diff : sample_t;
  signal q_sample_diff : sample_t;
  signal valid_diff    : std_ulogic;

  signal i_sample_del     : sample_t;
  signal q_sample_del     : sample_t;
  signal sample_del_valid : std_ulogic;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  fm_demod_o       <= fm_demod;
  fm_demod_valid_o <= fm_demod_valid;

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
      demod_part_a   <= (others => '0');
      demod_part_b   <= (others => '0');
      fm_demod       <= (others => '0');
      fm_demod_valid <= '0';
    end procedure reset;
  begin -- process regs
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
        -- Defaults
        fm_demod_valid <= '0';

        if valid_diff = '1' then
          demod_part_a <= ResizeTruncAbsVal(i_sample_del * q_sample_diff, demod_part_a);
          demod_part_b <= ResizeTruncAbsVal(q_sample_del * i_sample_diff, demod_part_b);

          -- TODO: is inverted (should be part_a-part_b)
          fm_demod       <= ResizeTruncAbsVal(demod_part_b - demod_part_a, fm_demod);
          fm_demod_valid <= '1';
        end if;
      end if;
    end if;
  end process regs;

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  DspFir_differentiator_i_inst : entity work.DspFir
    generic map(
      gB => filter_diff_coeffs_c)
    port map(
      iClk         => clk_i,
      inResetAsync => not rst_i,

      iDdry   => i_sample_i,
      iValDry => iq_valid_i,

      oDwet   => i_sample_diff,
      oValWet => valid_diff);

  DspFir_differentiator_q_inst : entity work.DspFir
    generic map(
      gB => filter_diff_coeffs_c)
    port map(
      iClk         => clk_i,
      inResetAsync => not rst_i,

      iDdry   => q_sample_i,
      iValDry => iq_valid_i,

      oDwet   => q_sample_diff,
      oValWet => open);

  delay_vector_i_inst : entity work.delay_vector
    generic map(
      gDelay => 3)
    port map(
      iClk         => clk_i,
      inResetAsync => not rst_i,

      iDdry   => i_sample_i,
      iValDry => iq_valid_i,

      oDwet   => i_sample_del,
      oValWet => sample_del_valid);

  delay_vector_q_inst : entity work.delay_vector
    generic map(
      gDelay => 3)
    port map(
      iClk         => clk_i,
      inResetAsync => not rst_i,

      iDdry   => q_sample_i,
      iValDry => iq_valid_i,

      oDwet   => q_sample_del,
      oValWet => open);

end architecture rtl;
