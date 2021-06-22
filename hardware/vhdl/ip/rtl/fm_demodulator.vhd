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
use work.fm_radio_pkg.all;

entity fm_demodulator is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    i_sample_i : in sample_t;
    q_sample_i : in sample_t;
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

  signal i_sample_diff : sample_t := (others => '0');
  signal q_sample_diff : sample_t := (others => '0');

  signal demod_part_a : sample_t := (others => '0');
  signal demod_part_b : sample_t := (others => '0');

  signal fm_demod       : sample_t   := (others => '0');
  signal fm_demod_valid : std_ulogic := '0';

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

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

  ------------------------------------------------------------------------------
  -- Signal Assignments
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Registers
  ----iResetAsync---------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
      i_sample_diff  <= (others => '0');
      q_sample_diff  <= (others => '0');
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

        if sample_del_valid = '1' then
          i_sample_diff <= ResizeTruncAbsVal(i_sample_i - i_sample_del, i_sample_diff);
          q_sample_diff <= ResizeTruncAbsVal(q_sample_i - q_sample_del, q_sample_diff);

          demod_part_a <= ResizeTruncAbsVal(i_sample_i * q_sample_diff, demod_part_a);
          demod_part_b <= ResizeTruncAbsVal(q_sample_i * i_sample_diff, demod_part_b);

          fm_demod       <= ResizeTruncAbsVal(demod_part_a - demod_part_b, fm_demod);
          fm_demod_valid <= '1';
        end if;
      end if;
    end if;
  end process regs;

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  delay_vector_i_inst : entity work.delay_vector
    generic map(
      gDelay => 3 + 2) -- NOTE: why +2 ??
    port map(
      iClk        => clk_i,
      iResetAsync => rst_i,

      iDdry   => i_sample_i,
      iValDry => iq_valid_i,

      oDwet   => i_sample_del,
      oValWet => sample_del_valid);

  delay_vector_q_inst : entity work.delay_vector
    generic map(
      gDelay => 3 + 2) -- NOTE: why +2 ??
    port map(
      iClk        => clk_i,
      iResetAsync => rst_i,

      iDdry   => q_sample_i,
      iValDry => iq_valid_i,

      oDwet   => q_sample_del,
      oValWet => open);

end architecture rtl;
