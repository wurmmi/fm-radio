-------------------------------------------------------------------------------
--! @file      fm_radio_axi.vhd
--! @author    Super Easy Register Scripting Engine (SERSE)
--! @copyright 2017 - 2021 Michael Wurm
--! @brief     AXI4-Lite register interface for FM Radio
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fm_radiolib;
use fm_radiolib.fm_radio_pkg.all;

--! @brief Entity declaration of fm_radio_axi
--! @details
--! This is a generated wrapper to combine registers into record types for
--! easier component connection in the design.

entity fm_radio_axi is
  generic (
    read_delay_g : natural := 2);
  port (
    --! @name AXI clock and reset
    --! @{

    s_axi_aclk_i    : in std_ulogic;
    s_axi_areset_i : in std_ulogic;

    --! @}
    --! @name AXI write address
    --! @{

    s_axi_awaddr_i  : in  std_ulogic_vector(1 downto 0);
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

    s_axi_araddr_i  : in  std_ulogic_vector(1 downto 0);
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

end entity fm_radio_axi;


--! RTL implementation of fm_radio_axi
architecture rtl of fm_radio_axi is
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
  --! @name FM Radio Registers
  -----------------------------------------------------------------------------
  --! @{

  signal fm_led_control_value : std_ulogic_vector(3 downto 0) := std_ulogic_vector(to_unsigned(0, 4));

  --! @}
  -----------------------------------------------------------------------------
  --! @name FM Radio Wires
  -----------------------------------------------------------------------------
  --! @{

  signal fm_magic_value_value : std_ulogic_vector(31 downto 0);
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

  control_o.led <= fm_led_control_value;

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  fm_magic_value_value <= status_i.magic_value;

  -----------------------------------------------------------------------------
  -- Registers
  -----------------------------------------------------------------------------

  regs : process (s_axi_aclk_i, s_axi_areset_i) is
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
    if s_axi_areset_i = '1' then
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

  reading : process (s_axi_aclk_i, s_axi_areset_i) is
    procedure reset is
    begin
      axi_rdata <= (others => '0');
      axi_rresp <= axi_addr_error_c;
    end procedure reset;
  begin -- process reading
    if s_axi_areset_i = '1' then
      reset;
    elsif rising_edge(s_axi_aclk_i) then
      -- Defaults
      axi_rdata <= (others => '0');
      axi_rresp <= axi_addr_error_c;

      case to_integer(axi_araddr) is
        when 0 =>
          axi_rdata(31 downto 0) <= fm_magic_value_value;
          axi_rresp <= axi_okay_c;

        when 4 =>
          axi_rdata(3 downto 0) <= fm_led_control_value;
          axi_rresp <= axi_okay_c;

        when others => null;
      end case;
    end if;
  end process reading;

  writing : process (s_axi_aclk_i, s_axi_areset_i) is
    procedure reset is
    begin
      axi_bresp <= axi_addr_error_c;

      fm_led_control_value <= std_ulogic_vector(to_unsigned(0, 4));
    end procedure reset;
  begin -- process writing
    if s_axi_areset_i = '1' then
      reset;
    elsif rising_edge(s_axi_aclk_i) then
      -- Defaults

      if axi_awready = '1' and axi_wready = '1' and
        s_axi_awvalid_i = '1' and s_axi_wvalid_i = '1'
      then
        -- Defaults
        axi_bresp <= axi_addr_error_c;

        case to_integer(axi_awaddr) is
          when 4 =>
            fm_led_control_value <= s_axi_wdata_i(3 downto 0);
            axi_bresp <= axi_okay_c;


        -- Clear interrupts

        -- Clear interrupt errors
          when others => null;
        end case;
      end if;

      -- Set interrupts

      -- Generate interrupts

      -- Set interrupt errors
    end if;
  end process writing;

end architecture rtl;
