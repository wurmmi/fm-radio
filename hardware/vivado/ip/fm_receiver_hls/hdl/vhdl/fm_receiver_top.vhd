-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2018.2
-- Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fm_receiver_top is
generic (
    C_S_AXI_CONFIG_ADDR_WIDTH : INTEGER := 5;
    C_S_AXI_CONFIG_DATA_WIDTH : INTEGER := 32 );
port (
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    iq_in_V_TDATA : IN STD_LOGIC_VECTOR (31 downto 0);
    iq_in_V_TVALID : IN STD_LOGIC;
    iq_in_V_TREADY : OUT STD_LOGIC;
    audio_out_V_TDATA : OUT STD_LOGIC_VECTOR (31 downto 0);
    audio_out_V_TVALID : OUT STD_LOGIC;
    audio_out_V_TREADY : IN STD_LOGIC;
    led_out : OUT STD_LOGIC_VECTOR (7 downto 0);
    led_out_ap_vld : OUT STD_LOGIC;
    s_axi_CONFIG_AWVALID : IN STD_LOGIC;
    s_axi_CONFIG_AWREADY : OUT STD_LOGIC;
    s_axi_CONFIG_AWADDR : IN STD_LOGIC_VECTOR (C_S_AXI_CONFIG_ADDR_WIDTH-1 downto 0);
    s_axi_CONFIG_WVALID : IN STD_LOGIC;
    s_axi_CONFIG_WREADY : OUT STD_LOGIC;
    s_axi_CONFIG_WDATA : IN STD_LOGIC_VECTOR (C_S_AXI_CONFIG_DATA_WIDTH-1 downto 0);
    s_axi_CONFIG_WSTRB : IN STD_LOGIC_VECTOR (C_S_AXI_CONFIG_DATA_WIDTH/8-1 downto 0);
    s_axi_CONFIG_ARVALID : IN STD_LOGIC;
    s_axi_CONFIG_ARREADY : OUT STD_LOGIC;
    s_axi_CONFIG_ARADDR : IN STD_LOGIC_VECTOR (C_S_AXI_CONFIG_ADDR_WIDTH-1 downto 0);
    s_axi_CONFIG_RVALID : OUT STD_LOGIC;
    s_axi_CONFIG_RREADY : IN STD_LOGIC;
    s_axi_CONFIG_RDATA : OUT STD_LOGIC_VECTOR (C_S_AXI_CONFIG_DATA_WIDTH-1 downto 0);
    s_axi_CONFIG_RRESP : OUT STD_LOGIC_VECTOR (1 downto 0);
    s_axi_CONFIG_BVALID : OUT STD_LOGIC;
    s_axi_CONFIG_BREADY : IN STD_LOGIC;
    s_axi_CONFIG_BRESP : OUT STD_LOGIC_VECTOR (1 downto 0) );
end;


architecture behav of fm_receiver_top is 
    attribute CORE_GENERATION_INFO : STRING;
    attribute CORE_GENERATION_INFO of behav : architecture is
    "fm_receiver_top,hls_ip_2018_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z020clg484-1,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=1.000000,HLS_SYN_LAT=2,HLS_SYN_TPT=none,HLS_SYN_MEM=0,HLS_SYN_DSP=0,HLS_SYN_FF=184,HLS_SYN_LUT=169,HLS_VERSION=2018_2}";
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (2 downto 0) := "001";
    constant ap_ST_fsm_state2 : STD_LOGIC_VECTOR (2 downto 0) := "010";
    constant ap_ST_fsm_state3 : STD_LOGIC_VECTOR (2 downto 0) := "100";
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv2_0 : STD_LOGIC_VECTOR (1 downto 0) := "00";
    constant ap_const_lv2_2 : STD_LOGIC_VECTOR (1 downto 0) := "10";
    constant ap_const_lv2_3 : STD_LOGIC_VECTOR (1 downto 0) := "11";
    constant ap_const_lv2_1 : STD_LOGIC_VECTOR (1 downto 0) := "01";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";
    constant C_S_AXI_DATA_WIDTH : INTEGER range 63 downto 0 := 20;
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_boolean_1 : BOOLEAN := true;

    signal ap_rst_n_inv : STD_LOGIC;
    signal iq_in_V_0_data_out : STD_LOGIC_VECTOR (31 downto 0);
    signal iq_in_V_0_vld_in : STD_LOGIC;
    signal iq_in_V_0_vld_out : STD_LOGIC;
    signal iq_in_V_0_ack_in : STD_LOGIC;
    signal iq_in_V_0_ack_out : STD_LOGIC;
    signal iq_in_V_0_payload_A : STD_LOGIC_VECTOR (31 downto 0);
    signal iq_in_V_0_payload_B : STD_LOGIC_VECTOR (31 downto 0);
    signal iq_in_V_0_sel_rd : STD_LOGIC := '0';
    signal iq_in_V_0_sel_wr : STD_LOGIC := '0';
    signal iq_in_V_0_sel : STD_LOGIC;
    signal iq_in_V_0_load_A : STD_LOGIC;
    signal iq_in_V_0_load_B : STD_LOGIC;
    signal iq_in_V_0_state : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal iq_in_V_0_state_cmp_full : STD_LOGIC;
    signal audio_out_V_1_data_out : STD_LOGIC_VECTOR (31 downto 0);
    signal audio_out_V_1_vld_in : STD_LOGIC;
    signal audio_out_V_1_vld_out : STD_LOGIC;
    signal audio_out_V_1_ack_in : STD_LOGIC;
    signal audio_out_V_1_ack_out : STD_LOGIC;
    signal audio_out_V_1_payload_A : STD_LOGIC_VECTOR (31 downto 0);
    signal audio_out_V_1_payload_B : STD_LOGIC_VECTOR (31 downto 0);
    signal audio_out_V_1_sel_rd : STD_LOGIC := '0';
    signal audio_out_V_1_sel_wr : STD_LOGIC := '0';
    signal audio_out_V_1_sel : STD_LOGIC;
    signal audio_out_V_1_load_A : STD_LOGIC;
    signal audio_out_V_1_load_B : STD_LOGIC;
    signal audio_out_V_1_state : STD_LOGIC_VECTOR (1 downto 0) := "00";
    signal audio_out_V_1_state_cmp_full : STD_LOGIC;
    signal led_ctrl : STD_LOGIC_VECTOR (7 downto 0);
    signal toggle : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal iq_in_V_TDATA_blk_n : STD_LOGIC;
    signal ap_CS_fsm : STD_LOGIC_VECTOR (2 downto 0) := "001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state2 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state2 : signal is "none";
    signal audio_out_V_TDATA_blk_n : STD_LOGIC;
    signal ap_CS_fsm_state3 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state3 : signal is "none";
    signal tmp_3_fu_76_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal ap_NS_fsm : STD_LOGIC_VECTOR (2 downto 0);

    component fm_receiver_top_CONFIG_s_axi IS
    generic (
        C_S_AXI_ADDR_WIDTH : INTEGER;
        C_S_AXI_DATA_WIDTH : INTEGER );
    port (
        AWVALID : IN STD_LOGIC;
        AWREADY : OUT STD_LOGIC;
        AWADDR : IN STD_LOGIC_VECTOR (C_S_AXI_ADDR_WIDTH-1 downto 0);
        WVALID : IN STD_LOGIC;
        WREADY : OUT STD_LOGIC;
        WDATA : IN STD_LOGIC_VECTOR (C_S_AXI_DATA_WIDTH-1 downto 0);
        WSTRB : IN STD_LOGIC_VECTOR (C_S_AXI_DATA_WIDTH/8-1 downto 0);
        ARVALID : IN STD_LOGIC;
        ARREADY : OUT STD_LOGIC;
        ARADDR : IN STD_LOGIC_VECTOR (C_S_AXI_ADDR_WIDTH-1 downto 0);
        RVALID : OUT STD_LOGIC;
        RREADY : IN STD_LOGIC;
        RDATA : OUT STD_LOGIC_VECTOR (C_S_AXI_DATA_WIDTH-1 downto 0);
        RRESP : OUT STD_LOGIC_VECTOR (1 downto 0);
        BVALID : OUT STD_LOGIC;
        BREADY : IN STD_LOGIC;
        BRESP : OUT STD_LOGIC_VECTOR (1 downto 0);
        ACLK : IN STD_LOGIC;
        ARESET : IN STD_LOGIC;
        ACLK_EN : IN STD_LOGIC;
        led_ctrl : OUT STD_LOGIC_VECTOR (7 downto 0) );
    end component;



begin
    fm_receiver_top_CONFIG_s_axi_U : component fm_receiver_top_CONFIG_s_axi
    generic map (
        C_S_AXI_ADDR_WIDTH => C_S_AXI_CONFIG_ADDR_WIDTH,
        C_S_AXI_DATA_WIDTH => C_S_AXI_CONFIG_DATA_WIDTH)
    port map (
        AWVALID => s_axi_CONFIG_AWVALID,
        AWREADY => s_axi_CONFIG_AWREADY,
        AWADDR => s_axi_CONFIG_AWADDR,
        WVALID => s_axi_CONFIG_WVALID,
        WREADY => s_axi_CONFIG_WREADY,
        WDATA => s_axi_CONFIG_WDATA,
        WSTRB => s_axi_CONFIG_WSTRB,
        ARVALID => s_axi_CONFIG_ARVALID,
        ARREADY => s_axi_CONFIG_ARREADY,
        ARADDR => s_axi_CONFIG_ARADDR,
        RVALID => s_axi_CONFIG_RVALID,
        RREADY => s_axi_CONFIG_RREADY,
        RDATA => s_axi_CONFIG_RDATA,
        RRESP => s_axi_CONFIG_RRESP,
        BVALID => s_axi_CONFIG_BVALID,
        BREADY => s_axi_CONFIG_BREADY,
        BRESP => s_axi_CONFIG_BRESP,
        ACLK => ap_clk,
        ARESET => ap_rst_n_inv,
        ACLK_EN => ap_const_logic_1,
        led_ctrl => led_ctrl);





    ap_CS_fsm_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                ap_CS_fsm <= ap_ST_fsm_state1;
            else
                ap_CS_fsm <= ap_NS_fsm;
            end if;
        end if;
    end process;


    audio_out_V_1_sel_rd_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                audio_out_V_1_sel_rd <= ap_const_logic_0;
            else
                if (((audio_out_V_1_ack_out = ap_const_logic_1) and (audio_out_V_1_vld_out = ap_const_logic_1))) then 
                                        audio_out_V_1_sel_rd <= not(audio_out_V_1_sel_rd);
                end if; 
            end if;
        end if;
    end process;


    audio_out_V_1_sel_wr_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                audio_out_V_1_sel_wr <= ap_const_logic_0;
            else
                if (((audio_out_V_1_ack_in = ap_const_logic_1) and (audio_out_V_1_vld_in = ap_const_logic_1))) then 
                                        audio_out_V_1_sel_wr <= not(audio_out_V_1_sel_wr);
                end if; 
            end if;
        end if;
    end process;


    audio_out_V_1_state_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                audio_out_V_1_state <= ap_const_lv2_0;
            else
                if ((((audio_out_V_1_state = ap_const_lv2_2) and (audio_out_V_1_vld_in = ap_const_logic_0)) or ((audio_out_V_1_state = ap_const_lv2_3) and (audio_out_V_1_vld_in = ap_const_logic_0) and (audio_out_V_1_ack_out = ap_const_logic_1)))) then 
                    audio_out_V_1_state <= ap_const_lv2_2;
                elsif ((((audio_out_V_1_state = ap_const_lv2_3) and (audio_out_V_1_ack_out = ap_const_logic_0) and (audio_out_V_1_vld_in = ap_const_logic_1)) or ((audio_out_V_1_state = ap_const_lv2_1) and (audio_out_V_1_ack_out = ap_const_logic_0)))) then 
                    audio_out_V_1_state <= ap_const_lv2_1;
                elsif ((((audio_out_V_1_state = ap_const_lv2_2) and (audio_out_V_1_vld_in = ap_const_logic_1)) or (not(((audio_out_V_1_vld_in = ap_const_logic_0) and (audio_out_V_1_ack_out = ap_const_logic_1))) and not(((audio_out_V_1_ack_out = ap_const_logic_0) and (audio_out_V_1_vld_in = ap_const_logic_1))) and (audio_out_V_1_state = ap_const_lv2_3)) or ((audio_out_V_1_state = ap_const_lv2_1) and (audio_out_V_1_ack_out = ap_const_logic_1)))) then 
                    audio_out_V_1_state <= ap_const_lv2_3;
                else 
                    audio_out_V_1_state <= ap_const_lv2_2;
                end if; 
            end if;
        end if;
    end process;


    iq_in_V_0_sel_rd_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                iq_in_V_0_sel_rd <= ap_const_logic_0;
            else
                if (((iq_in_V_0_ack_out = ap_const_logic_1) and (iq_in_V_0_vld_out = ap_const_logic_1))) then 
                                        iq_in_V_0_sel_rd <= not(iq_in_V_0_sel_rd);
                end if; 
            end if;
        end if;
    end process;


    iq_in_V_0_sel_wr_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                iq_in_V_0_sel_wr <= ap_const_logic_0;
            else
                if (((iq_in_V_0_ack_in = ap_const_logic_1) and (iq_in_V_0_vld_in = ap_const_logic_1))) then 
                                        iq_in_V_0_sel_wr <= not(iq_in_V_0_sel_wr);
                end if; 
            end if;
        end if;
    end process;


    iq_in_V_0_state_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                iq_in_V_0_state <= ap_const_lv2_0;
            else
                if ((((iq_in_V_0_vld_in = ap_const_logic_0) and (iq_in_V_0_state = ap_const_lv2_2)) or ((iq_in_V_0_vld_in = ap_const_logic_0) and (iq_in_V_0_state = ap_const_lv2_3) and (iq_in_V_0_ack_out = ap_const_logic_1)))) then 
                    iq_in_V_0_state <= ap_const_lv2_2;
                elsif ((((iq_in_V_0_ack_out = ap_const_logic_0) and (iq_in_V_0_state = ap_const_lv2_1)) or ((iq_in_V_0_ack_out = ap_const_logic_0) and (iq_in_V_0_state = ap_const_lv2_3) and (iq_in_V_0_vld_in = ap_const_logic_1)))) then 
                    iq_in_V_0_state <= ap_const_lv2_1;
                elsif (((not(((iq_in_V_0_vld_in = ap_const_logic_0) and (iq_in_V_0_ack_out = ap_const_logic_1))) and not(((iq_in_V_0_ack_out = ap_const_logic_0) and (iq_in_V_0_vld_in = ap_const_logic_1))) and (iq_in_V_0_state = ap_const_lv2_3)) or ((iq_in_V_0_state = ap_const_lv2_1) and (iq_in_V_0_ack_out = ap_const_logic_1)) or ((iq_in_V_0_state = ap_const_lv2_2) and (iq_in_V_0_vld_in = ap_const_logic_1)))) then 
                    iq_in_V_0_state <= ap_const_lv2_3;
                else 
                    iq_in_V_0_state <= ap_const_lv2_2;
                end if; 
            end if;
        end if;
    end process;

    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((audio_out_V_1_load_A = ap_const_logic_1)) then
                audio_out_V_1_payload_A <= iq_in_V_0_data_out;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((audio_out_V_1_load_B = ap_const_logic_1)) then
                audio_out_V_1_payload_B <= iq_in_V_0_data_out;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((iq_in_V_0_load_A = ap_const_logic_1)) then
                iq_in_V_0_payload_A <= iq_in_V_TDATA;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((iq_in_V_0_load_B = ap_const_logic_1)) then
                iq_in_V_0_payload_B <= iq_in_V_TDATA;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((audio_out_V_1_ack_in = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state3))) then
                toggle <= tmp_3_fu_76_p2;
            end if;
        end if;
    end process;

    ap_NS_fsm_assign_proc : process (iq_in_V_0_vld_out, audio_out_V_1_ack_in, ap_CS_fsm, ap_CS_fsm_state2, ap_CS_fsm_state3)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                ap_NS_fsm <= ap_ST_fsm_state2;
            when ap_ST_fsm_state2 => 
                if ((not(((audio_out_V_1_ack_in = ap_const_logic_0) or (iq_in_V_0_vld_out = ap_const_logic_0))) and (ap_const_logic_1 = ap_CS_fsm_state2))) then
                    ap_NS_fsm <= ap_ST_fsm_state3;
                else
                    ap_NS_fsm <= ap_ST_fsm_state2;
                end if;
            when ap_ST_fsm_state3 => 
                if (((audio_out_V_1_ack_in = ap_const_logic_1) and (ap_const_logic_1 = ap_CS_fsm_state3))) then
                    ap_NS_fsm <= ap_ST_fsm_state1;
                else
                    ap_NS_fsm <= ap_ST_fsm_state3;
                end if;
            when others =>  
                ap_NS_fsm <= "XXX";
        end case;
    end process;
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state2 <= ap_CS_fsm(1);
    ap_CS_fsm_state3 <= ap_CS_fsm(2);

    ap_rst_n_inv_assign_proc : process(ap_rst_n)
    begin
                ap_rst_n_inv <= not(ap_rst_n);
    end process;

    audio_out_V_1_ack_in <= audio_out_V_1_state(1);
    audio_out_V_1_ack_out <= audio_out_V_TREADY;

    audio_out_V_1_data_out_assign_proc : process(audio_out_V_1_payload_A, audio_out_V_1_payload_B, audio_out_V_1_sel)
    begin
        if ((audio_out_V_1_sel = ap_const_logic_1)) then 
            audio_out_V_1_data_out <= audio_out_V_1_payload_B;
        else 
            audio_out_V_1_data_out <= audio_out_V_1_payload_A;
        end if; 
    end process;

    audio_out_V_1_load_A <= (not(audio_out_V_1_sel_wr) and audio_out_V_1_state_cmp_full);
    audio_out_V_1_load_B <= (audio_out_V_1_state_cmp_full and audio_out_V_1_sel_wr);
    audio_out_V_1_sel <= audio_out_V_1_sel_rd;
    audio_out_V_1_state_cmp_full <= '0' when (audio_out_V_1_state = ap_const_lv2_1) else '1';

    audio_out_V_1_vld_in_assign_proc : process(iq_in_V_0_vld_out, audio_out_V_1_ack_in, ap_CS_fsm_state2)
    begin
        if ((not(((audio_out_V_1_ack_in = ap_const_logic_0) or (iq_in_V_0_vld_out = ap_const_logic_0))) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            audio_out_V_1_vld_in <= ap_const_logic_1;
        else 
            audio_out_V_1_vld_in <= ap_const_logic_0;
        end if; 
    end process;

    audio_out_V_1_vld_out <= audio_out_V_1_state(0);
    audio_out_V_TDATA <= audio_out_V_1_data_out;

    audio_out_V_TDATA_blk_n_assign_proc : process(audio_out_V_1_state, ap_CS_fsm_state2, ap_CS_fsm_state3)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state3) or (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            audio_out_V_TDATA_blk_n <= audio_out_V_1_state(1);
        else 
            audio_out_V_TDATA_blk_n <= ap_const_logic_1;
        end if; 
    end process;

    audio_out_V_TVALID <= audio_out_V_1_state(0);
    iq_in_V_0_ack_in <= iq_in_V_0_state(1);

    iq_in_V_0_ack_out_assign_proc : process(iq_in_V_0_vld_out, audio_out_V_1_ack_in, ap_CS_fsm_state2)
    begin
        if ((not(((audio_out_V_1_ack_in = ap_const_logic_0) or (iq_in_V_0_vld_out = ap_const_logic_0))) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            iq_in_V_0_ack_out <= ap_const_logic_1;
        else 
            iq_in_V_0_ack_out <= ap_const_logic_0;
        end if; 
    end process;


    iq_in_V_0_data_out_assign_proc : process(iq_in_V_0_payload_A, iq_in_V_0_payload_B, iq_in_V_0_sel)
    begin
        if ((iq_in_V_0_sel = ap_const_logic_1)) then 
            iq_in_V_0_data_out <= iq_in_V_0_payload_B;
        else 
            iq_in_V_0_data_out <= iq_in_V_0_payload_A;
        end if; 
    end process;

    iq_in_V_0_load_A <= (iq_in_V_0_state_cmp_full and not(iq_in_V_0_sel_wr));
    iq_in_V_0_load_B <= (iq_in_V_0_state_cmp_full and iq_in_V_0_sel_wr);
    iq_in_V_0_sel <= iq_in_V_0_sel_rd;
    iq_in_V_0_state_cmp_full <= '0' when (iq_in_V_0_state = ap_const_lv2_1) else '1';
    iq_in_V_0_vld_in <= iq_in_V_TVALID;
    iq_in_V_0_vld_out <= iq_in_V_0_state(0);

    iq_in_V_TDATA_blk_n_assign_proc : process(iq_in_V_0_state, ap_CS_fsm_state2)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state2)) then 
            iq_in_V_TDATA_blk_n <= iq_in_V_0_state(0);
        else 
            iq_in_V_TDATA_blk_n <= ap_const_logic_1;
        end if; 
    end process;

    iq_in_V_TREADY <= iq_in_V_0_state(1);
    led_out <= led_ctrl;

    led_out_ap_vld_assign_proc : process(ap_CS_fsm_state1)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state1)) then 
            led_out_ap_vld <= ap_const_logic_1;
        else 
            led_out_ap_vld <= ap_const_logic_0;
        end if; 
    end process;

    tmp_3_fu_76_p2 <= (toggle xor ap_const_lv1_1);
end behav;
