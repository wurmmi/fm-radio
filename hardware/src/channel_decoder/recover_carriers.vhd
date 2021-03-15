-------------------------------------------------------------------------------
--! @file      recover_carriers.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Recover Carriers implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fm_pkg.all;
use work.filter_lp_mono_pkg.all;

entity recover_carriers is
  port (
    clk_i : in std_ulogic;
    rst_i : in std_ulogic;

    sample_i       : in sample_t;
    sample_valid_i : in std_ulogic;

    carrier_38k_o       : out sample_t;
    carrier_38k_valid_o : out std_ulogic;
    carrier_57k_o       : out sample_t;
    carrier_57k_valid_o : out std_ulogic);

end entity recover_carriers;

architecture rtl of recover_carriers is

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
  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  carrier_57k_o       <= (others => '0');
  carrier_57k_valid_o <= '0';

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
    end procedure reset;
  begin -- process regs
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
      end if;
    end if;
  end process regs;

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  dspfir_inst : entity work.DspFir
    generic map(
      gB => filter_bp_pilot_coeffs_c)
    port map(
      iClk         => clk_i,
      inResetAsync => not rst_i,
      iDdry        => fir_i,
      iValDry      => fir_valid_i,
      oDwet        => fir_o,
      oValWet      => fir_valid_o);

end architecture rtl;
