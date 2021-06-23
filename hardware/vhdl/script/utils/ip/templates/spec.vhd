-------------------------------------------------------------------------------
--! @file      {{name|pretty}}_spec_pkg.vhd
--! @author    Super Easy Register Scripting Engine (SERSE)
--! @copyright 2017-2021 Michael Wurm
--! @brief     Specification package for {{name}}
-------------------------------------------------------------------------------

package {{name|pretty}}_spec_pkg is
  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  -- Number of registers in AXI register map
  constant spec_num_registers_c     : natural := {{map|length}};

  -- Register interface address bus width
  constant spec_reg_if_addr_width_c : natural := {{addr_width}};

  -- Constants inferred from {{name|pretty}}.yaml
  {% for reg in map %}
  {% if reg.const %}
  constant {{reg.const}} : natural := {{reg.size}};
  {% endif %}
  {% endfor %}

  --! @}

end package {{name|pretty}}_spec_pkg;

package body {{name|pretty}}_spec_pkg is
end package body {{name|pretty}}_spec_pkg;

