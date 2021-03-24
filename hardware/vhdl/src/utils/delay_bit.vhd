-------------------------------------------------------------------------------
--! @file      delay_bit.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Configurable delay.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fm_global_pkg.all;

--! @brief Entity declaration of delay_bit
--! @details
--! The delay_bit implementation.

entity delay_bit is
  generic (
    --! Initial value of input signal
    init_value_g : std_ulogic := '0';

    --! Number of delay_bit stages
    num_delay_g : positive := 2);
  port (
    --! @name Clocks and resets
    --! @{

    --! System clock
    clk_i : in std_ulogic;

    --! @}
    --! @name Delay signals
    --! @{

    --! Enable
    en_i : in std_ulogic;
    --! Input signal
    sig_i : in std_ulogic;
    --! Delayed signal
    dlyd_o : out std_ulogic);

  --! @}
end entity delay_bit;

--! RTL implementation of delay_bit
architecture rtl of delay_bit is

  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal sig : std_ulogic_vector(num_delay_g - 1 downto 0) := (others => init_value_g);

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal next_sig : std_ulogic_vector(num_delay_g - 1 downto 0);

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  dlyd_o <= sig(sig'high);

  ------------------------------------------------------------------------------
  -- Signal Assignments
  ------------------------------------------------------------------------------

  --! Delay only for one clock cycle
  single_delay_gen : if num_delay_g = 1 generate
    next_sig(0) <= sig_i;
  end generate single_delay_gen;

  --! Delay for multiple clock cycles
  multiple_delays_gen : if num_delay_g > 1 generate
    next_sig <= sig(sig'high - 1 downto sig'low) & sig_i;
  end generate multiple_delays_gen;

  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  regs : process (clk_i) is
  begin -- process regs
    if rising_edge(clk_i) then
      if en_i = '1' then
        sig <= next_sig;
      end if;
    end if;
  end process regs;

end architecture rtl;
