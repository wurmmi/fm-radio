-------------------------------------------------------------------------------
--! @file      {{name|pretty}}_axi.vhd
--! @author    Super Easy Register Scripting Engine (SERSE)
--! @copyright 2017 - 2021 Michael Wurm
--! @brief     AXI4-Lite register interface for {{name}}
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library {{name|pretty}}lib;
use {{name|pretty}}lib.{{name|pretty}}_pkg.all;

--! @brief Entity declaration of {{name|pretty}}_axi
--! @details
--! This is a generated wrapper to combine registers into record types for
--! easier component connection in the design.

entity {{name|pretty}}_axi is
  generic (
    read_delay_g : natural := 2);
  port (
    --! @name AXI clock and reset
    --! @{

    s_axi_aclk_i    : in std_ulogic;
    s_axi_aresetn_i : in std_ulogic;

    --! @}
    --! @name AXI write address
    --! @{

    s_axi_awaddr_i  : in  std_ulogic_vector({{(addr_width|int)-1}} downto 0);
    s_axi_awprot_i  : in  std_ulogic_vector(2 downto 0);
    s_axi_awvalid_i : in  std_ulogic;
    s_axi_awready_o : out std_ulogic;

    --! @}
    --! @name AXI write data
    --! @{

    s_axi_wdata_i  : in  std_ulogic_vector(31 downto 0);
    s_axi_wstrb_i  : in  std_ulogic_vector(3 downto 0);
    s_axi_wvalid_i : in  std_ulogic;
    s_axi_wready_o : out std_ulogic;

    --! @}
    --! @name AXI write response
    --! @{

    s_axi_bresp_o  : out std_ulogic_vector(1 downto 0);
    s_axi_bvalid_o : out std_ulogic;
    s_axi_bready_i : in  std_ulogic;

    --! @}
    --! @name AXI read address
    --! @{

    s_axi_araddr_i  : in  std_ulogic_vector({{(addr_width|int)-1}} downto 0);
    s_axi_arprot_i  : in  std_ulogic_vector(2 downto 0);
    s_axi_arvalid_i : in  std_ulogic;
    s_axi_arready_o : out std_ulogic;

    --! @}
    --! @name AXI read data
    --! @{

    s_axi_rdata_o  : out std_ulogic_vector(31 downto 0);
    s_axi_rresp_o  : out std_ulogic_vector(1 downto 0);
    s_axi_rvalid_o : out std_ulogic;
    s_axi_rready_i : in  std_ulogic;

    --! @}
    --! @name Register interface
    --! @{

    status_i    : in  status_t;
    control_o   : out control_t;
    interrupt_o : out interrupt_t);

    --! @}

end entity {{name|pretty}}_axi;


--! RTL implementation of {{name|pretty}}_axi
architecture rtl of {{name|pretty}}_axi is
  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  constant axi_okay_c       : std_ulogic_vector(1 downto 0) := "00";
  constant axi_addr_error_c : std_ulogic_vector(1 downto 0) := "11";

  --! @}
  -----------------------------------------------------------------------------
  --! @name AXI Registers
  -----------------------------------------------------------------------------
  --! @{

  signal axi_awready : std_ulogic;
  signal axi_awaddr  : unsigned(s_axi_awaddr_i'range);
  signal axi_wready  : std_ulogic;
  signal axi_bvalid  : std_ulogic;
  signal axi_bresp   : std_ulogic_vector(s_axi_bresp_o'range);
  signal axi_arready : std_ulogic;
  signal axi_araddr  : unsigned(s_axi_araddr_i'range);
  signal axi_rvalid  : std_ulogic_vector(read_delay_g-1 downto 0);
  signal axi_rdata   : std_ulogic_vector(s_axi_rdata_o'range);
  signal axi_rresp   : std_ulogic_vector(s_axi_rresp_o'range);

  --! @}
  -----------------------------------------------------------------------------
  --! @name {{name}} Registers
  -----------------------------------------------------------------------------
  --! @{

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

begin -- architecture rtl

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------

  s_axi_awready_o <= axi_awready;
  s_axi_wready_o  <= axi_wready;
  s_axi_bvalid_o  <= axi_bvalid;
  s_axi_bresp_o   <= axi_bresp;
  s_axi_arready_o <= axi_arready;
  s_axi_rvalid_o  <= axi_rvalid(axi_rvalid'high);
  s_axi_rdata_o   <= axi_rdata;
  s_axi_rresp_o   <= axi_rresp;

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

  regs : process (s_axi_aclk_i, s_axi_aresetn_i) is
    procedure reset is
    begin
      axi_awready <= '0';
      axi_awaddr  <= (others => '0');
      axi_wready  <= '0';
      axi_bvalid  <= '0';
      axi_arready <= '0';
      axi_araddr  <= (others => '0');
      axi_rvalid  <= (others => '0');
    end procedure reset;
  begin -- process regs
    if s_axi_aresetn_i = '0' then
      reset;
    elsif rising_edge(s_axi_aclk_i) then
      -- Defaults
      axi_awready <= '0';
      axi_wready  <= '0';
      axi_arready <= '0';

      -- Write
      if axi_awready = '0' and s_axi_awvalid_i = '1' and
        s_axi_wvalid_i = '1'
      then
        axi_awready <= '1';
        axi_awaddr  <= unsigned(s_axi_awaddr_i);
      end if;

      if axi_wready = '0' and s_axi_awvalid_i = '1' and
        s_axi_wvalid_i = '1'
      then
        axi_wready <= '1';
      end if;

      if axi_awready = '1' and axi_wready = '1' and
        s_axi_awvalid_i = '1' and s_axi_wvalid_i = '1'
      then
        -- NOTE: This is where the write operation happens
        -- See process "writing" below

        axi_bvalid <= '1';
      end if;

      if s_axi_bready_i = '1' and axi_bvalid = '1' then
        axi_bvalid <= '0';
      end if;

      -- Read
      if axi_arready = '0' and s_axi_arvalid_i = '1' then
        axi_arready <= '1';
        axi_araddr  <= unsigned(s_axi_araddr_i);
      end if;

      axi_rvalid <= axi_rvalid(axi_rvalid'high-1 downto axi_rvalid'low) & '0';

      if axi_arready = '1' and s_axi_arvalid_i = '1' and
        axi_rvalid = (axi_rvalid'range => '0')
      then
        -- NOTE: This is where the read operation happens
        -- See process "reading" below

        axi_rvalid(axi_rvalid'low) <= '1';
      end if;

      if axi_rvalid(axi_rvalid'high) = '1' and s_axi_rready_i = '1' then
        axi_rvalid <= (others => '0');
        axi_araddr <= (others => '0');
      end if;
    end if;
  end process regs;

  reading : process (s_axi_aclk_i, s_axi_aresetn_i) is
    procedure reset is
    begin
      axi_rdata <= (others => '0');
      axi_rresp <= axi_addr_error_c;
    end procedure reset;
  begin -- process reading
    if s_axi_aresetn_i = '0' then
      reset;
    elsif rising_edge(s_axi_aclk_i) then
      -- Defaults
      axi_rdata <= (others => '0');
      axi_rresp <= axi_addr_error_c;

      case to_integer(axi_araddr) is
      {% for reg in map %}
      {% if reg.access != "WRITE_ONLY" %}
        when {{reg.offset}} =>
        {% for field in reg.fields %}
        {% if field.width > 1 %}
          axi_rdata({{field.width + field.offset - 1}} downto {{field.offset}}) <= {{reg.full|pretty}}_{{field.name|pretty}};
        {% else %}
          axi_rdata({{field.offset}}) <= {{reg.full|pretty}}_{{field.name|pretty}};
        {% endif %}
        {% endfor %}
          axi_rresp <= axi_okay_c;

      {% endif %}
      {% endfor %}
        when others => null;
      end case;
    end if;
  end process reading;

  writing : process (s_axi_aclk_i, s_axi_aresetn_i) is
    procedure reset is
    begin
      axi_bresp <= axi_addr_error_c;

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
    if s_axi_aresetn_i = '0' then
      reset;
    elsif rising_edge(s_axi_aclk_i) then
      -- Defaults
      {% for reg in map %}
      {% if reg.strobe and (reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE") %}
      {{reg.full|pretty}}_valid <= '0';
      {% endif %}
      {% endfor %}

      if axi_awready = '1' and axi_wready = '1' and
        s_axi_awvalid_i = '1' and s_axi_wvalid_i = '1'
      then
        -- Defaults
        axi_bresp <= axi_addr_error_c;

        case to_integer(axi_awaddr) is
        {% for reg in map %}
        {% if reg.access == "WRITE_ONLY" or reg.access == "READ_WRITE" %}
          when {{reg.offset}} =>
        {% if reg.strobe %}
            {{reg.full|pretty}}_valid <= '1';
        {% endif %}
        {% for field in reg.fields %}
        {% if field.width > 1 %}
            {{reg.full|pretty}}_{{field.name|pretty}} <= s_axi_wdata_i({{field.width + field.offset - 1}} downto {{field.offset}});
        {% else %}
            {{reg.full|pretty}}_{{field.name|pretty}} <= s_axi_wdata_i({{field.offset}});
        {% endif %}
        {% endfor %}
            axi_bresp <= axi_okay_c;

        {% endif %}
        {% endfor %}

        -- Clear interrupts
        {% for reg in map %}
        {% if reg.access == "INTERRUPT" %}
          when {{reg.offset}} =>
        {% for field in reg.fields %}
            if s_axi_wdata_i({{field.offset}}) = '1' then
              {{reg.full|pretty}}_{{field.name|pretty}} <= '0';
            end if;
        {% endfor %}
            axi_bresp <= axi_okay_c;

        {% endif %}
        {% endfor %}

        -- Clear interrupt errors
        {% for reg in map %}
        {% if reg.access == "INTERRUPT_ERROR" %}
          when {{reg.offset}} =>
        {% for field in reg.fields %}
            if s_axi_wdata_i({{field.offset}}) = '1' then
              {{reg.full|pretty}}_{{field.name|pretty}} <= '0';
            end if;
        {% endfor %}
            axi_bresp <= axi_okay_c;

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

