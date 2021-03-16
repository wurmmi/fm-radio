-------------------------------------------------------------------------------
--! @file      recover_carriers.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Recover Carriers implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_pkg.all;
use work.filter_bp_pilot_pkg.all;

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

  -- TODO: get this constant from pilot_pkg.vhdl
  constant pilot_scale_factor_c : u_sfixed(4 downto 0) := to_sfixed(7, 4, 0);

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

  signal pilot_fir       : sample_t;
  signal pilot_fir_valid : std_ulogic;
  signal pilot           : sample_t;
  signal pilot_valid     : std_ulogic;

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
        -- Defaults
        pilot_valid <= '0';

        if pilot_fir_valid = '1' then
          pilot       <= ResizeTruncAbsVal(pilot_fir * pilot_scale_factor_c, pilot);
          pilot_valid <= '1';
        end if;
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

      iDdry   => sample_i,
      iValDry => sample_valid_i,

      oDwet   => pilot_fir,
      oValWet => pilot_fir_valid);

end architecture rtl;
