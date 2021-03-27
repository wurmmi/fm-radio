-------------------------------------------------------------------------------
--! @file      strobe_gen.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2017-2019 Michael Wurm
--! @brief     Entity implementation of strobe_gen.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.fm_global_pkg.all;

--! @brief Entity declaration of strobe_gen
--! @details
--! Generates a strobe signal that will be '1' for one clock cycle
--! of clk_i. The strobe comes every period_g. If this cycle time
--! cannot be generated exactly it will be truncated with the
--! accuracy of one clk_i cycle.

entity strobe_gen is
  generic (
    --! System clock frequency
    clk_freq_g : natural := clk_freq_system_c;
    --! Period between two strobes
    period_g : time := 100 us);
  port (
    --! @name Clocks and resets
    --! @{

    --! System clock
    clk_i : in std_logic;
    --! Asynchronous reset
    rst_i : in std_logic;

    --! @}
    --! @name Strobe signals
    --! @{

    --! Enable
    enable_i : in std_ulogic;
    --! Generated strobe
    strobe_o : out std_ulogic);

  --! @}

begin

  report "strobe_gen: period_g is = " & time'image(period_g);

  -- pragma translate_off
  assert ((1 sec / clk_freq_g) <= period_g)
  report "strobe_gen: The Clk frequency is to low to generate such a short strobe cycle."
    severity error;
  -- pragma translate_on

end entity strobe_gen;

--! RTL implementation of strobe_gen
architecture rtl of strobe_gen is
  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  constant clks_per_strobe_c : natural := clk_freq_g / (1 sec / period_g);

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal count : unsigned(log_dualis(clks_per_strobe_c) downto 0);

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal strobe : std_ulogic;

  --! @}

begin -- architecture rtl

  strobe_o <= strobe;

  -- Count the number of Clk cycles from strobe pulse to strobe pulse.
  regs : process (clk_i) is
    procedure reset is
    begin
      count  <= to_unsigned(0, count'length);
      strobe <= '0';
    end procedure reset;
  begin -- process strobe
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
        if enable_i = '1' then
          if count = clks_per_strobe_c - 1 then
            count  <= (others => '0');
            strobe <= '1';
          else
            count  <= count + 1;
            strobe <= '0';
          end if;
        end if;
      end if;
    end process regs;

  end architecture rtl;
