-------------------------------------------------------------------------------
--! @file      {{name|pretty}}_av_mm.vhd
--! @author    Super Easy Register Scripting Engine (SERSE)
--! @copyright 2017 - 2021 Michael Wurm
--! @brief     Avalon MM register interface for {{name}}
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library {{name|pretty}}lib;
use {{name|pretty}}lib.{{name|pretty}}_pkg.all;

--! @brief Entity declaration of {{name|pretty}}_av_mm
--! @details
--! This is a generated wrapper to combine registers into record types for
--! easier component connection in the design.

entity {{name|pretty}}_av_mm is
  generic (
    read_delay_g : natural := 2);
  port (
    --! @name Clock and reset
    --! @{

    clk_i   : in std_ulogic;
    rst_n_i : in std_ulogic;

    --! @}
    --! @name Avalon MM Interface
    --! @{

    s1_address_i   : in  std_ulogic_vector({{(addr_width|int)-1}} downto 0);
    s1_write_i     : in  std_ulogic;
    s1_writedata_i : in  std_ulogic_vector(31 downto 0);
    s1_read_i      : in  std_ulogic;
    s1_readdata_o  : out std_ulogic_vector(31 downto 0);
    s1_readdatavalid_o  : out std_ulogic;
    s1_response_o  : out std_ulogic_vector(1 downto 0);

    --! @}
    --! @name Register interface
    --! @{

    status_i    : in  status_t;
    control_o   : out control_t;
    interrupt_o : out interrupt_t);

    --! @}

end entity {{name|pretty}}_av_mm;


architecture rtl of {{name|pretty}}_av_mm is

  -----------------------------------------------------------------------------
  --! @name {{name}} Avalon MM Constants
  -----------------------------------------------------------------------------
  --! @{

  constant response_okay_c       : std_ulogic_vector(1 downto 0) := b"00";
  constant response_reserved_c   : std_ulogic_vector(1 downto 0) := b"01";
  constant response_slave_err_c  : std_ulogic_vector(1 downto 0) := b"10";
  constant response_decode_err_c : std_ulogic_vector(1 downto 0) := b"11";

  --! @}
  -----------------------------------------------------------------------------
  --! @name {{name}} Registers
  -----------------------------------------------------------------------------
  --! @{

  signal rdvalid  : std_ulogic_vector(read_delay_g-1 downto 0) := (others => '0');
  signal response : std_ulogic_vector(1 downto 0) := response_decode_err_c;
  signal rresp    : std_ulogic_vector(1 downto 0) := response_decode_err_c;
  signal wresp    : std_ulogic_vector(1 downto 0) := response_decode_err_c;
  signal raddr    : natural range 0 to {{addr_max}};

  {% for reg in map %}
  {% if reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE" or reg.access == "INTERRUPT" or reg.access == "INTERRUPT_ERROR" %}
  {% if reg.strobe %}
  signal {{reg.full|pretty}}_valid : std_ulogic := '0';
  {% endif %}
  {% if reg.access == "INTERRUPT" %}
  signal {{reg.full|pretty}} : std_ulogic := '0';
  {% endif %}
  {% for field in reg.fields %}
  {% if field.width > 1 %}
  signal {{reg.full|pretty}}_{{field.name|pretty}} : std_ulogic_vector({{field.width - 1}} downto 0) := std_ulogic_vector(to_unsigned({{field.reset}}, {{field.width}}));
  {% else %}
  signal {{reg.full|pretty}}_{{field.name|pretty}} : std_ulogic := '{{field.reset}}';
  {% endif %}
  {% endfor %}
  {% endif %}
  {% endfor %}

  --! @}
  -----------------------------------------------------------------------------
  --! @name {{name}} Wires
  -----------------------------------------------------------------------------
  --! @{

  signal addr     : natural range 0 to {{addr_max}};
  signal readdata : std_ulogic_vector(s1_readdata_o'range);

  {% for reg in map %}
  {% for field in reg.fields %}
  {% if reg.access == "INTERRUPT" %}
  signal {{reg.full|pretty}}_{{field.name|pretty}}_set : std_ulogic;
  {% endif %}
  {% if field.width > 1 %}
  {% if not (reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE" or reg.access == "INTERRUPT" or reg.access == "INTERRUPT_ERROR") %}
  signal {{reg.full|pretty}}_{{field.name|pretty}} : std_ulogic_vector({{field.width - 1}} downto 0);
  {% endif %}
  {% else %}
  {% if not (reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE" or reg.access == "INTERRUPT" or reg.access == "INTERRUPT_ERROR") %}
  signal {{reg.full|pretty}}_{{field.name|pretty}} : std_ulogic;
  {% endif %}
  {% endif %}
  {% endfor %}
  {% endfor %}

  --! @}

begin

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------

  s1_readdata_o      <= readdata;
  s1_response_o      <= response;
  s1_readdatavalid_o <= rdvalid(rdvalid'high);

  {% for reg in map %}
  {% if reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE" %}
  {% if reg.strobe %}
  {{reg.strobe}} <= {{reg.full|pretty}}_valid;
  {% endif %}
  {% for field in reg.fields %}
  {% if field.connect %}
  {{field.connect}} <= {{reg.full|pretty}}_{{field.name|pretty}};
  {% endif %}
  {% endfor %}
  {% endif %}
  {% if reg.access == "INTERRUPT" %}
  {{reg.strobe}} <= {{reg.full|pretty}};
  {% endif %}
  {% endfor %}

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  addr <= to_integer(unsigned(s1_address_i));
  response <= rresp when rdvalid(rdvalid'high) = '1' else
              wresp when s1_write_i = '1' else
              response_decode_err_c;

  {% for reg in map %}
  {% if reg.access == "READ_ONLY" %}
  {% for field in reg.fields %}
  {% if field.connect %}
  {{reg.full|pretty}}_{{field.name|pretty}} <= {{field.connect}};
  {% endif %}
  {% endfor %}
  {% endif %}
  {% if reg.access == "INTERRUPT" %}
  {% for field in reg.fields %}
  {% if field.connect %}
  {{reg.full|pretty}}_{{field.name|pretty}}_set <= {{field.connect}};
  {% endif %}
  {% endfor %}
  {% endif %}
  {% endfor %}

  -----------------------------------------------------------------------------
  -- Registers
  -----------------------------------------------------------------------------

  regs : process (clk_i, rst_n_i) is
  procedure reset is
  begin
  end procedure reset;
  begin
    if rst_n_i = '0' then
      reset;
    elsif rising_edge(clk_i) then
      -- Defaults
      rdvalid <= rdvalid(read_delay_g-2 downto 0) & '0';

      if s1_read_i = '1' and rdvalid = (rdvalid'range => '0') then
        rdvalid(rdvalid'low) <= '1';
        raddr <= addr;
      end if;
    end if;
  end process regs;

  reading : process (clk_i, rst_n_i) is
  procedure reset is
  begin
    readdata <= (others => '0');
    --rdvalid <= (others => '0');
    rresp <= response_decode_err_c;
  end procedure reset;
  begin -- process reading
    if rst_n_i = '0' then
      reset;
    elsif rising_edge(clk_i) then
      -- Defaults
      readdata <= (others => '0');
      rresp <= response_decode_err_c;

      if rdvalid(rdvalid'low) = '1' then
        case raddr is
        {% for reg in map %}
        {% if reg.access != "WRITE_ONLY" %}
          when {{reg.offset}} =>
          {% for field in reg.fields %}
          {% if field.width > 1 %}
            readdata({{field.width + field.offset - 1}} downto {{field.offset}}) <= {{reg.full|pretty}}_{{field.name|pretty}};
          {% else %}
            readdata({{field.offset}}) <= {{reg.full|pretty}}_{{field.name|pretty}};
          {% endif %}
          {% endfor %}
            rresp <= response_okay_c;

        {% endif %}
        {% endfor %}
          when others => null;
        end case;
      end if;
    end if;
  end process reading;

  writing : process (clk_i, rst_n_i) is
  procedure reset is
  begin
    wresp <= response_decode_err_c;

    {% for reg in map %}
    {% if reg.strobe and (reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE") %}
    {{reg.full|pretty}}_valid <= '0';
    {% endif %}
    {% if reg.access == "INTERRUPT" %}
    {{reg.full|pretty}} <= '0';
    {% endif %}
    {% if reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE" or reg.access == "INTERRUPT" or reg.access == "INTERRUPT_ERROR" %}
    {% for field in reg.fields %}
    {% if field.width > 1 %}
    {{reg.full|pretty}}_{{field.name|pretty}} <= std_ulogic_vector(to_unsigned({{field.reset}}, {{field.width}}));
    {% else %}
    {{reg.full|pretty}}_{{field.name|pretty}} <= '{{field.reset}}';
    {% endif %}
    {% endfor %}
    {% endif %}
    {% endfor %}
  end procedure reset;
  begin -- process writing
    if rst_n_i = '0' then
      reset;
    elsif rising_edge(clk_i) then
      -- Defaults
      {% for reg in map %}
      {% if reg.strobe and (reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE") %}
      {{reg.full|pretty}}_valid <= '0';
      {% endif %}
      {% endfor %}

      if s1_write_i = '1' then
        wresp <= response_decode_err_c;

        case addr is
        {% for reg in map %}
        {% if reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE" %}
          when {{reg.offset}} =>
        {% if reg.strobe %}
            {{reg.full|pretty}}_valid <= '1';
        {% endif %}
        {% for field in reg.fields %}
        {% if field.width > 1 %}
            {{reg.full|pretty}}_{{field.name|pretty}} <= s1_writedata_i({{field.width + field.offset - 1}} downto {{field.offset}});
        {% else %}
            {{reg.full|pretty}}_{{field.name|pretty}} <= s1_writedata_i({{field.offset}});
        {% endif %}
        {% endfor %}
            wresp <= response_okay_c;

        {% endif %}
        {% endfor %}

        -- Clear interrupts
        {% for reg in map %}
        {% if reg.access == "INTERRUPT" %}
          when {{reg.offset}} =>
        {% for field in reg.fields %}
            if s1_writedata_i({{field.offset}}) = '1' then
              {{reg.full|pretty}}_{{field.name|pretty}} <= '0';
            end if;
        {% endfor %}
            wresp <= response_okay_c;
        {% endif %}
        {% endfor %}

        -- Clear interrupt errors
        {% for reg in map %}
        {% if reg.access == "INTERRUPT_ERROR" %}
          when {{reg.offset}} =>
        {% for field in reg.fields %}
            if s1_writedata_i({{field.offset}}) = '1' then
              {{reg.full|pretty}}_{{field.name|pretty}} <= '0';
            end if;
        {% endfor %}
            wresp <= response_okay_c;

        {% endif %}
        {% endfor %}
          when others => null;
        end case;
      end if;

      -- Set interrupts
      {% for reg in map %}
      {% if reg.access == "INTERRUPT" %}
      {% for field in reg.fields %}
      if {{reg.full|pretty}}_{{field.name|pretty}}_set = '1' then
        {{reg.full|pretty}}_{{field.name|pretty}} <= '1';
      end if;
      {% endfor %}
      {% endif %}
      {% endfor %}

      -- Generate interrupts
      {% for reg in map %}
      {% if reg.access == "INTERRUPT" %}
      if
      {% for field in reg.fields %}
      {% if loop.last %}
        {{reg.full|pretty}}_{{field.name|pretty}} = '1'
      {% else %}
        {{reg.full|pretty}}_{{field.name|pretty}} = '1' or
      {% endif %}
      {% endfor %}
      then
        {{reg.full|pretty}} <= '1';
      else
        {{reg.full|pretty}} <= '0';
      end if;
      {% endif %}
      {% endfor %}

      -- Set interrupt errors
      {% for reg in map %}
      {% if reg.access == "INTERRUPT_ERROR" %}
      {% for field in reg.fields %}
      if {{field.connect|pretty}}_{{field.name|pretty}} = '1' and
         {{field.connect|pretty}}_{{field.name|pretty}}_set = '1'
      then
        {{reg.full|pretty}}_{{field.name|pretty}} <= '1';
      end if;

      {% endfor %}
      {% endif %}
      {% endfor %}
    end if;
  end process writing;

end architecture rtl;
