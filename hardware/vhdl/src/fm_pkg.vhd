-------------------------------------------------------------------------------
--! @file      fm_pkg.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     Global package with types and constants.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.fixed_float_types.all;

library work;
use work.fm_global_pkg.all;

package fm_pkg is

  ------------------------------------------------------------------------------
  -- Types and Constants
  ------------------------------------------------------------------------------

  --! Oversampling rate fs:fs_rx
  constant osr_rx_c : natural := osr_rx_spec_c;

  --! Fixed point bitwidths
  constant fp_width_c      : natural := fp_width_spec_c;
  constant fp_width_frac_c : natural := fp_width_frac_spec_c;
  constant fp_width_int_c  : natural := fp_width_int_spec_c;

  --! Pilot recovery
  constant pilot_scale_factor_c : u_sfixed(4 downto 0)  := to_sfixed(pilot_scale_factor_spec_c, 4, 0);
  constant carrier_38k_offset_c : u_sfixed(0 downto -2) := to_sfixed(carrier_38k_offset_spec_c, 0, -2);

  --! Value
  subtype iq_value_t is u_sfixed(fp_width_int_c downto -fp_width_frac_c);

  subtype sample_t is u_sfixed(fp_width_int_c downto -fp_width_frac_c);

  subtype fract_real is real range
  - 1.0 to 0.99999999999999999999999999999999999999999999999999999999999999999;

  type filter_coeffs_t is array (natural range <>) of fract_real;

  ------------------------------------------------------------------------------
  -- Function Definitions
  ------------------------------------------------------------------------------
  -- function log2 returns the logarithm of base 2 as an integer
  function LogDualis(cNumber : natural) return natural;

  -- ***
  -- NOTE: Need to "use ieee.fixed_pkg.all;" everywhere this function is used!!
  -- ***
  -- Resize and truncate
  function ResizeTruncAbsVal (
    arg      : u_sfixed; -- input
    size_res : u_sfixed) -- for size only
    return sfixed;

end package fm_pkg;

package body fm_pkg is

  -- Function LogDualis returns the logarithm of base 2 as an integer.
  -- Although the implementation of this function was not done with synthesis
  -- efficiency in mind, the function has to be synthesizable, because it is
  -- often used in static calculations.
  function LogDualis(cNumber : natural) return natural is
    -- Initialize explicitly (will have warnings for uninitialized variables
    -- from Quartus synthesis otherwise).
    variable vClimbUp : natural := 1;
    variable vResult  : natural := 0;
  begin
    while vClimbUp < cNumber loop
      vClimbUp := vClimbUp * 2;
      vResult  := vResult + 1;
    end loop;
    return vResult;
  end LogDualis;

  -- ***
  -- NOTE: Need to "use ieee.fixed_pkg.all;" everywhere this function is used!!
  -- ***
  -- Resize and truncate
  function ResizeTruncAbsVal (
    arg      : u_sfixed;
    size_res : u_sfixed)
    return sfixed is

    variable lsb : u_sfixed(size_res'range)                        := (others => '0');
    variable tmp : u_sfixed(size_res'high + 1 downto size_res'low) := (others => '0');
  begin
    lsb(lsb'low)        := '1';
    tmp(size_res'range) := resize(
    arg            => arg,
    left_index     => size_res'high,
    right_index    => size_res'low,
    round_style    => fixed_truncate,
    overflow_style => fixed_saturate);

    if tmp < 0 and arg >- 1 then
      tmp := tmp(size_res'range) + lsb;
    end if;
    return tmp(size_res'range);
  end function ResizeTruncAbsVal;

end package body fm_pkg;
