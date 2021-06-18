-------------------------------------------------------------------------------
--! @file      recover_carriers.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Recover carriers implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_radio_pkg.all;
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
  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal pilot       : sample_t   := (others => '0');
  signal pilot_valid : std_ulogic := '0';

  signal carrier_38k       : sample_t   := (others => '0');
  signal carrier_38k_valid : std_ulogic := '0';

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal pilot_fir       : sample_t;
  signal pilot_fir_valid : std_ulogic;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  carrier_38k_o       <= carrier_38k;
  carrier_38k_valid_o <= carrier_38k_valid;

  carrier_57k_o       <= (others => '0');
  carrier_57k_valid_o <= '0';

  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  regs : process (clk_i) is
    procedure reset is
    begin
      pilot             <= (others => '0');
      pilot_valid       <= '0';
      carrier_38k       <= (others => '0');
      carrier_38k_valid <= '0';
    end procedure reset;
  begin -- process regs
    if rising_edge(clk_i) then
      if rst_i = '1' then
        reset;
      else
        -- Defaults
        pilot_valid       <= '0';
        carrier_38k_valid <= '0';

        -- Amplify the filtered pilot
        if pilot_fir_valid = '1' then
          pilot       <= ResizeTruncAbsVal(pilot_fir * pilot_scale_factor_c, pilot);
          pilot_valid <= '1';
        end if;

        -- Create the 38kHz carrier
        if pilot_valid = '1' then
          carrier_38k <= ResizeTruncAbsVal(
            pilot * pilot * to_sfixed(2, 2, 0) - carrier_38k_offset_c, carrier_38k);

          carrier_38k_valid <= '1';
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
