-------------------------------------------------------------------------------
--! @file      fm_receiver_top.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2021 Michael Wurm
--! @brief     FM Receiver top-level implementation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- TIME LOGGING
--
-- (1) Top-level AXI stream interface (input) implementation
--       03/27/2021  15:30 - 17:30    2:00 h
--
-- (2) Top-level AXI stream interface (output) implementation
--       06/16/2021  08:30 - 10:00    1:30 h   VHDL implementation fast; But
--                                             testbench verification took 3h ..
--
-- (3) AXI-Lite register interface
--       06/18/2021  08:00 - 18:00   10:00 h   Register interface already tested and auto-generated!
--                                             But took a long time to bring it into Vivado. (create IF in IP Packager, figure out Address Range error, etc.)
--
-- (4) LED control
--       06/19/2021  13:30 - 15:30    2:00 h
--
-- (5) Mode
--       06/22/2021  16:00 - 17:00    1:00 h
--
-- (6) Top-level AXI stream interface (input / output) implementation
--       06/23/2021  13:00 - 18:00    5:00 h   Had to re-work the entire logic around the stream interface ...
--                                             Big effort in working out and implementing FSM, etc. compared to HLS.
--                                             Still not an optimum solution. Used a 'work-around' to throttle the input.
--                                             Optimum solution: stream interface in ALL entities throughout the design (like HLS).
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.fm_radio_spec_pkg.all;
use work.fm_radio_pkg.all;

entity fm_receiver_top is
  port (
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    -- AXI stream input
    s0_axis_tready : out std_logic;
    s0_axis_tdata  : in std_logic_vector(31 downto 0);
    s0_axis_tvalid : in std_logic;

    -- AXI stream output
    m0_axis_tready : in std_logic;
    m0_axis_tdata  : out std_logic_vector(31 downto 0);
    m0_axis_tvalid : out std_logic;

    -- LED output
    leds_o : out std_logic_vector(3 downto 0);

    -- AXI-Lite register interface
    -- NOTE: Adapt address widths in the IP Packager if they change! (awaddr, araddr)
    s_axi_awaddr  : in std_logic_vector(spec_reg_if_addr_width_c - 1 downto 0);
    s_axi_awprot  : in std_logic_vector(2 downto 0);
    s_axi_awvalid : in std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in std_logic_vector(31 downto 0);
    s_axi_wstrb   : in std_logic_vector(3 downto 0);
    s_axi_wvalid  : in std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in std_logic;
    s_axi_araddr  : in std_logic_vector(spec_reg_if_addr_width_c - 1 downto 0);
    s_axi_arprot  : in std_logic_vector(2 downto 0);
    s_axi_arvalid : in std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in std_logic);

end entity fm_receiver_top;

architecture rtl of fm_receiver_top is

  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  type fsm_state_t is (S0_reset, S1_WaitForThrottleStrobe, S2_ProcessValidInput, S3_WaitForReadyOutput);

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  signal nextState : fsm_state_t := S0_reset;

  signal tready : std_ulogic := '0';

  signal i_sample : sample_t   := (others => '0');
  signal q_sample : sample_t   := (others => '0');
  signal iq_valid : std_ulogic := '0';

  signal led_toggle : std_ulogic := '0';

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  signal rst        : std_ulogic;
  signal req_sample : std_ulogic;

  signal audio_L     : sample_t;
  signal audio_R     : sample_t;
  signal audio_valid : std_ulogic;

  signal status  : status_t;
  signal control : control_t;

  --! @}

begin -- architecture rtl

  ------------------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------------------

  mode_switch : process (clk_i, control.enable_fm_radio) is
  begin
    case control.enable_fm_radio is
        -- Mode: Passthrough
      when '0' =>
        s0_axis_tready <= m0_axis_tready;
        m0_axis_tdata  <= s0_axis_tdata;
        m0_axis_tvalid <= s0_axis_tvalid;

        -- Mode: FM Radio
      when '1' =>
        s0_axis_tready <= tready;

        m0_axis_tdata(31 downto 16) <= std_logic_vector(to_slv(audio_L));
        m0_axis_tdata(15 downto 0)  <= std_logic_vector(to_slv(audio_R));
        m0_axis_tvalid              <= std_logic(audio_valid);
      when others => null;
    end case;
  end process mode_switch;

  leds_o(3 downto 1) <= std_logic_vector(control.led_ctrl);
  leds_o(0)          <= led_toggle;

  ------------------------------------------------------------------------------
  -- Signal Assignments
  ------------------------------------------------------------------------------

  status.magic_value <= x"DEADBEEF";

  -- Invert reset
  rst <= not rst_n_i;

  ------------------------------------------------------------------------------
  -- Registers
  ------------------------------------------------------------------------------

  -- FSM functionality:
  --   1.  Wait for strobe (to throttle the input)
  --   2.  Wait for valid input and consume an input sample
  --   2a. An output sample is produced by the IP --> goto 3
  --   2b. No output sample produced yet --> goto 1
  --   3.  Wait until the downstream IP (axi-stream-to-i2s converter) is ready.
  --       Once it becomes ready, goto 1.
  regs : process (clk_i) is
    procedure reset is
    begin
      tready    <= '0';
      nextState <= S0_reset;

      iq_valid <= '0';
      i_sample <= (others => '0');
      q_sample <= (others => '0');
    end procedure reset; begin
    if rising_edge(clk_i) then
      if rst = '1' then
        reset;
      else
        -- Defaults
        iq_valid <= '0';
        if audio_valid = '1' then
          led_toggle <= not led_toggle;
        end if;

        case nextState is
          when S0_reset =>
            reset;
            nextState <= S1_WaitForThrottleStrobe;

          when S1_WaitForThrottleStrobe =>
            if req_sample = '1' then
              tready    <= '1';
              nextState <= S2_ProcessValidInput;
            end if;

          when S2_ProcessValidInput =>
            if s0_axis_tvalid = '1' then
              tready   <= '0';
              i_sample <= to_sfixed(s0_axis_tdata(15 downto 0), i_sample);
              q_sample <= to_sfixed(s0_axis_tdata(31 downto 16), q_sample);
              iq_valid <= '1';
            end if;
            if audio_valid = '1' then
              tready    <= '0';
              nextState <= S3_WaitForReadyOutput;
            else
              nextState <= S1_WaitForThrottleStrobe;
            end if;

          when S3_WaitForReadyOutput =>
            if m0_axis_tready = '1' then
              nextState <= S1_WaitForThrottleStrobe;
            end if;
          when others =>
            assert false report "unknown/unhandled nextState" severity error;
        end case;
      end if;
    end if;
  end process regs;

  ------------------------------------------------------------------------------
  -- Instantiations
  ------------------------------------------------------------------------------

  -- Strobe generator to throttle streaming input
  strobe_gen_inst : entity work.strobe_gen
    generic map(
      clk_freq_g => clk_freq_system_c,
      period_g   => (1 sec / fs_c))
    port map(
      clk_i => clk_i,
      rst_i => rst,

      enable_i => '1',
      strobe_o => req_sample);

  -- FM receiver IP
  fm_receiver_inst : entity work.fm_receiver
    port map(
      clk_i => clk_i,
      rst_i => rst,

      i_sample_i => i_sample,
      q_sample_i => q_sample,
      iq_valid_i => iq_valid,

      audio_L_o     => audio_L,
      audio_R_o     => audio_R,
      audio_valid_o => audio_valid);

  -- AXI-lite register map
  registers_inst : entity work.fm_radio_axi
    port map(
      s_axi_aclk_i   => clk_i,
      s_axi_areset_i => rst,

      s_axi_awaddr_i              => std_ulogic_vector(s_axi_awaddr),
      s_axi_awprot_i              => std_ulogic_vector(s_axi_awprot),
      s_axi_awvalid_i             => std_ulogic(s_axi_awvalid),
      std_ulogic(s_axi_awready_o) => s_axi_awready,

      s_axi_wdata_i              => std_ulogic_vector(s_axi_wdata),
      s_axi_wstrb_i              => std_ulogic_vector(s_axi_wstrb),
      s_axi_wvalid_i             => std_ulogic(s_axi_wvalid),
      std_ulogic(s_axi_wready_o) => s_axi_wready,

      std_ulogic_vector(s_axi_bresp_o) => s_axi_bresp,
      std_ulogic(s_axi_bvalid_o)       => s_axi_bvalid,
      s_axi_bready_i                   => std_ulogic(s_axi_bready),

      s_axi_araddr_i              => std_ulogic_vector(s_axi_araddr),
      s_axi_arprot_i              => std_ulogic_vector(s_axi_arprot),
      s_axi_arvalid_i             => std_ulogic(s_axi_arvalid),
      std_ulogic(s_axi_arready_o) => s_axi_arready,

      std_ulogic_vector(s_axi_rdata_o) => s_axi_rdata,
      std_ulogic_vector(s_axi_rresp_o) => s_axi_rresp,
      std_ulogic(s_axi_rvalid_o)       => s_axi_rvalid,
      s_axi_rready_i                   => std_ulogic(s_axi_rready),

      status_i    => status,
      control_o   => control,
      interrupt_o => open);

end architecture rtl;
