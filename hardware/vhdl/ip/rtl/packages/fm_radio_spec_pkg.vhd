-------------------------------------------------------------------------------
--! @file      fm_radio_spec_pkg.vhd
--! @author    Super Easy Register Scripting Engine (SERSE)
--! @copyright 2017 - 2021 Michael Wurm
--! @brief     Specification package for FM Radio
-------------------------------------------------------------------------------

package fm_radio_spec_pkg is
  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  -- Number of registers in AXI register map
  constant spec_num_registers_c     : natural := 3;

  -- Register interface address bus width
  constant spec_reg_if_addr_width_c : natural := 12;

  -- Constants inferred from fm_radio.yaml

  --! @}

end package fm_radio_spec_pkg;

package body fm_radio_spec_pkg is
end package body fm_radio_spec_pkg;
