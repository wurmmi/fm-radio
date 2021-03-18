-------------------------------------------------------------------------------
--! @file      decimator.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Decimator implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_pkg.all;

entity decimator is
  generic (
    decimation_g : natural := 8);
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i       : in sample_t;
    sample_valid_i : in std_ulogic;

    sample_o       : out sample_t;
    sample_valid_o : out std_ulogic);

end entity decimator;

architecture rtl of decimator is

  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal count : natural range 0 to decimation_g - 1 := 0;

  signal sample : sample_t   := (others => '0');
  signal valid  : std_ulogic := '0';

  --! @}

begin -- architecture rtl

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------

  sample_valid_o <= valid;
  sample_o       <= sample;

  -----------------------------------------------------------------------------
  -- Registers
  -----------------------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
      valid  <= '0';
      count  <= 0;
      sample <= (others => '0');
    end procedure;
  begin -- process regs
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
        -- Defaults
        valid <= '0';

        if sample_valid_i = '1' then
          if count = decimation_g - 1 then
            count <= 0;

            valid  <= '1';
            sample <= sample_i;
          else
            count <= count + 1;
          end if;
        end if;
      end if;
    end if;
  end process regs;

end architecture rtl;
