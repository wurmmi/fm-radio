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

package fm_pkg is

  ------------------------------------------------------------------------------
  -- Types and Constants
  ------------------------------------------------------------------------------

  --! Value
  subtype iq_value_t is std_ulogic_vector(26 downto 0);


  subtype sample_t is u_sfixed(0 downto -15);

  ------------------------------------------------------------------------------
  -- Function Definitions
  ------------------------------------------------------------------------------
  -- function log2 returns the logarithm of base 2 as an integer
  function LogDualis(cNumber : natural) return natural;

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
      vResult  := vResult+1;
    end loop;
    return vResult;
  end LogDualis;

end package body fm_pkg;
