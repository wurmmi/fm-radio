-------------------------------------------------------------------------------
--! @file      fm_radio_rom.vhd
--! @author    Super Easy Register Scripting Engine (SERSE)
--! @copyright 2017-2021 Michael Wurm
--! @brief     Read-only memory for FM Radio
--
-- This file is generated by SERSE.
-- *** DO NOT MODIFY ***
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Entity declaration of fm_radio_rom
--! @details
--! This is a generated ROM.

entity fm_radio_rom is
  port (
    --! @name Clocks and resets
    --! @{

    --! System clock
    clk_i : in std_ulogic;

    --! @}
    --! @name Interface
    --! @{

    --! Address
    addr_i : in std_ulogic_vector(3 downto 0);
    --! Data
    data_o : out std_ulogic_vector(31 downto 0));

  --! @}
end entity fm_radio_rom;

--! RTL implementation of fm_radio_rom
architecture rtl of fm_radio_rom is

  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  --! ROM
  type rom_t is array (0 to 2 ** addr_i'length - 1) of
  std_ulogic_vector(data_o'range);

  --! ROM content
  constant rom_c : rom_t := (
    0 => x"00210629",
    1 => x"00211552",
    2 => x"32f12dd3",
    others => (others => '0'));

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal data : std_ulogic_vector(data_o'range) := (others => '0');

  --! @}

begin -- architecture rtl

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------

  data_o <= data;

  -----------------------------------------------------------------------------
  -- Registers
  -----------------------------------------------------------------------------

  regs : process (clk_i) is
  begin -- process regs
    if rising_edge(clk_i) then
      data <= rom_c(to_integer(unsigned(addr_i)));
    end if;
  end process regs;

end architecture rtl;