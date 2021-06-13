-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2018.2
-- Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fm_receiver_hls is
generic (
    C_S_AXI_API_ADDR_WIDTH : INTEGER := 6;
    C_S_AXI_API_DATA_WIDTH : INTEGER := 32 );
port (
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    iq_in_V_TDATA : IN STD_LOGIC_VECTOR (31 downto 0);
    iq_in_V_TVALID : IN STD_LOGIC;
    iq_in_V_TREADY : OUT STD_LOGIC;
    audio_out_V_TDATA : OUT STD_LOGIC_VECTOR (31 downto 0);
    audio_out_V_TVALID : OUT STD_LOGIC;
    audio_out_V_TREADY : IN STD_LOGIC;
    led_out : OUT STD_LOGIC_VECTOR (7 downto 0);
    s_axi_API_AWVALID : IN STD_LOGIC;
    s_axi_API_AWREADY : OUT STD_LOGIC;
    s_axi_API_AWADDR : IN STD_LOGIC_VECTOR (C_S_AXI_API_ADDR_WIDTH-1 downto 0);
    s_axi_API_WVALID : IN STD_LOGIC;
    s_axi_API_WREADY : OUT STD_LOGIC;
    s_axi_API_WDATA : IN STD_LOGIC_VECTOR (C_S_AXI_API_DATA_WIDTH-1 downto 0);
    s_axi_API_WSTRB : IN STD_LOGIC_VECTOR (C_S_AXI_API_DATA_WIDTH/8-1 downto 0);
    s_axi_API_ARVALID : IN STD_LOGIC;
    s_axi_API_ARREADY : OUT STD_LOGIC;
    s_axi_API_ARADDR : IN STD_LOGIC_VECTOR (C_S_AXI_API_ADDR_WIDTH-1 downto 0);
    s_axi_API_RVALID : OUT STD_LOGIC;
    s_axi_API_RREADY : IN STD_LOGIC;
    s_axi_API_RDATA : OUT STD_LOGIC_VECTOR (C_S_AXI_API_DATA_WIDTH-1 downto 0);
    s_axi_API_RRESP : OUT STD_LOGIC_VECTOR (1 downto 0);
    s_axi_API_BVALID : OUT STD_LOGIC;
    s_axi_API_BREADY : IN STD_LOGIC;
    s_axi_API_BRESP : OUT STD_LOGIC_VECTOR (1 downto 0) );
end;


architecture behav of fm_receiver_hls is 
    attribute CORE_GENERATION_INFO : STRING;
    attribute CORE_GENERATION_INFO of behav : architecture is
    "fm_receiver_hls,hls_ip_2018_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z020clg484-1,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=8.457000,HLS_SYN_LAT=2855,HLS_SYN_TPT=none,HLS_SYN_MEM=11,HLS_SYN_DSP=6,HLS_SYN_FF=1374,HLS_SYN_LUT=1915,HLS_VERSION=2018_2}";
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (3 downto 0) := "0001";
    constant ap_ST_fsm_state2 : STD_LOGIC_VECTOR (3 downto 0) := "0010";
    constant ap_ST_fsm_state3 : STD_LOGIC_VECTOR (3 downto 0) := "0100";
    constant ap_ST_fsm_state4 : STD_LOGIC_VECTOR (3 downto 0) := "1000";
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv2_0 : STD_LOGIC_VECTOR (1 downto 0) := "00";
    constant ap_const_lv2_2 : STD_LOGIC_VECTOR (1 downto 0) := "10";
    constant ap_const_lv2_3 : STD_LOGIC_VECTOR (1 downto 0) := "11";
    constant ap_const_lv2_1 : STD_LOGIC_VECTOR (1 downto 0) := "01";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";
    constant ap_const_lv32_3 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000011";
    constant C_S_AXI_DATA_WIDTH : INTEGER range 63 downto 0 := 20;
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv28_4DB729F : STD_LOGIC_VECTOR (27 downto 0) := "0100110110110111001010011111";
    constant ap_const_lv48_210613132455 : STD_LOGIC_VECTOR (47 downto 0) := "001000010000011000010011000100110010010001010101";
    constant ap_const_lv8_2 : STD_LOGIC_VECTOR (7 downto 0) := "00000010";
    constant ap_const_boolean_1 : BOOLEAN := true;

    signal ap_rst_n_inv : STD_LOGIC;
    signal ap_CS_fsm : STD_LOGIC_VECTOR (3 downto 0) := "0001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
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
    signal config_led_ctrl : STD_LOGIC_VECTOR (7 downto 0);
    signal toggle : STD_LOGIC_VECTOR (0 downto 0) := "0";
    signal audio_out_V_TDATA_blk_n : STD_LOGIC;
    signal ap_CS_fsm_state3 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state3 : signal is "none";
    signal ap_CS_fsm_state4 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state4 : signal is "none";
    signal tmp5_fu_158_p3 : STD_LOGIC_VECTOR (31 downto 0);
    signal grp_fm_receiver_fu_122_ap_idle : STD_LOGIC;
    signal grp_fm_receiver_fu_122_ap_ready : STD_LOGIC;
    signal grp_fm_receiver_fu_122_ap_done : STD_LOGIC;
    signal grp_fm_receiver_fu_122_ap_start : STD_LOGIC;
    signal grp_fm_receiver_fu_122_iq_in_V_TVALID : STD_LOGIC;
    signal grp_fm_receiver_fu_122_iq_in_V_TREADY : STD_LOGIC;
    signal grp_fm_receiver_fu_122_ap_return_0 : STD_LOGIC_VECTOR (15 downto 0);
    signal grp_fm_receiver_fu_122_ap_return_1 : STD_LOGIC_VECTOR (15 downto 0);
    signal grp_fm_receiver_fu_122_ap_start_reg : STD_LOGIC := '0';
    signal ap_CS_fsm_state2 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state2 : signal is "none";
    signal toggle_assign_fu_171_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_NS_fsm : STD_LOGIC_VECTOR (3 downto 0);

    component fm_receiver IS
    port (
        ap_clk : IN STD_LOGIC;
        ap_rst : IN STD_LOGIC;
        ap_start : IN STD_LOGIC;
        ap_done : OUT STD_LOGIC;
        ap_idle : OUT STD_LOGIC;
        ap_ready : OUT STD_LOGIC;
        iq_in_V_TDATA : IN STD_LOGIC_VECTOR (31 downto 0);
        iq_in_V_TVALID : IN STD_LOGIC;
        iq_in_V_TREADY : OUT STD_LOGIC;
        ap_return_0 : OUT STD_LOGIC_VECTOR (15 downto 0);
        ap_return_1 : OUT STD_LOGIC_VECTOR (15 downto 0) );
    end component;


    component fm_receiver_hls_API_s_axi IS
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
        config_led_ctrl : OUT STD_LOGIC_VECTOR (7 downto 0);
        status_git_hash_V : IN STD_LOGIC_VECTOR (27 downto 0);
        status_build_time_V : IN STD_LOGIC_VECTOR (47 downto 0) );
    end component;



begin
    fm_receiver_hls_API_s_axi_U : component fm_receiver_hls_API_s_axi
    generic map (
        C_S_AXI_ADDR_WIDTH => C_S_AXI_API_ADDR_WIDTH,
        C_S_AXI_DATA_WIDTH => C_S_AXI_API_DATA_WIDTH)
    port map (
        AWVALID => s_axi_API_AWVALID,
        AWREADY => s_axi_API_AWREADY,
        AWADDR => s_axi_API_AWADDR,
        WVALID => s_axi_API_WVALID,
        WREADY => s_axi_API_WREADY,
        WDATA => s_axi_API_WDATA,
        WSTRB => s_axi_API_WSTRB,
        ARVALID => s_axi_API_ARVALID,
        ARREADY => s_axi_API_ARREADY,
        ARADDR => s_axi_API_ARADDR,
        RVALID => s_axi_API_RVALID,
        RREADY => s_axi_API_RREADY,
        RDATA => s_axi_API_RDATA,
        RRESP => s_axi_API_RRESP,
        BVALID => s_axi_API_BVALID,
        BREADY => s_axi_API_BREADY,
        BRESP => s_axi_API_BRESP,
        ACLK => ap_clk,
        ARESET => ap_rst_n_inv,
        ACLK_EN => ap_const_logic_1,
        config_led_ctrl => config_led_ctrl,
        status_git_hash_V => ap_const_lv28_4DB729F,
        status_build_time_V => ap_const_lv48_210613132455);

    grp_fm_receiver_fu_122 : component fm_receiver
    port map (
        ap_clk => ap_clk,
        ap_rst => ap_rst_n_inv,
        ap_start => grp_fm_receiver_fu_122_ap_start,
        ap_done => grp_fm_receiver_fu_122_ap_done,
        ap_idle => grp_fm_receiver_fu_122_ap_idle,
        ap_ready => grp_fm_receiver_fu_122_ap_ready,
        iq_in_V_TDATA => iq_in_V_0_data_out,
        iq_in_V_TVALID => grp_fm_receiver_fu_122_iq_in_V_TVALID,
        iq_in_V_TREADY => grp_fm_receiver_fu_122_iq_in_V_TREADY,
        ap_return_0 => grp_fm_receiver_fu_122_ap_return_0,
        ap_return_1 => grp_fm_receiver_fu_122_ap_return_1);





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
                if (((audio_out_V_1_vld_in = ap_const_logic_1) and (audio_out_V_1_ack_in = ap_const_logic_1))) then 
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
                elsif ((((audio_out_V_1_state = ap_const_lv2_1) and (audio_out_V_1_ack_out = ap_const_logic_0)) or ((audio_out_V_1_state = ap_const_lv2_3) and (audio_out_V_1_ack_out = ap_const_logic_0) and (audio_out_V_1_vld_in = ap_const_logic_1)))) then 
                    audio_out_V_1_state <= ap_const_lv2_1;
                elsif (((not(((audio_out_V_1_vld_in = ap_const_logic_0) and (audio_out_V_1_ack_out = ap_const_logic_1))) and not(((audio_out_V_1_ack_out = ap_const_logic_0) and (audio_out_V_1_vld_in = ap_const_logic_1))) and (audio_out_V_1_state = ap_const_lv2_3)) or ((audio_out_V_1_state = ap_const_lv2_1) and (audio_out_V_1_ack_out = ap_const_logic_1)) or ((audio_out_V_1_state = ap_const_lv2_2) and (audio_out_V_1_vld_in = ap_const_logic_1)))) then 
                    audio_out_V_1_state <= ap_const_lv2_3;
                else 
                    audio_out_V_1_state <= ap_const_lv2_2;
                end if; 
            end if;
        end if;
    end process;


    grp_fm_receiver_fu_122_ap_start_reg_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst_n_inv = '1') then
                grp_fm_receiver_fu_122_ap_start_reg <= ap_const_logic_0;
            else
                if ((ap_const_logic_1 = ap_CS_fsm_state2)) then 
                    grp_fm_receiver_fu_122_ap_start_reg <= ap_const_logic_1;
                elsif ((grp_fm_receiver_fu_122_ap_ready = ap_const_logic_1)) then 
                    grp_fm_receiver_fu_122_ap_start_reg <= ap_const_logic_0;
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
                if ((((iq_in_V_0_state = ap_const_lv2_2) and (iq_in_V_0_vld_in = ap_const_logic_0)) or ((iq_in_V_0_state = ap_const_lv2_3) and (iq_in_V_0_vld_in = ap_const_logic_0) and (iq_in_V_0_ack_out = ap_const_logic_1)))) then 
                    iq_in_V_0_state <= ap_const_lv2_2;
                elsif ((((iq_in_V_0_state = ap_const_lv2_1) and (iq_in_V_0_ack_out = ap_const_logic_0)) or ((iq_in_V_0_state = ap_const_lv2_3) and (iq_in_V_0_ack_out = ap_const_logic_0) and (iq_in_V_0_vld_in = ap_const_logic_1)))) then 
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
                audio_out_V_1_payload_A <= tmp5_fu_158_p3;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((audio_out_V_1_load_B = ap_const_logic_1)) then
                audio_out_V_1_payload_B <= tmp5_fu_158_p3;
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
            if (((ap_const_logic_1 = ap_CS_fsm_state4) and (audio_out_V_1_ack_in = ap_const_logic_1))) then
                toggle <= toggle_assign_fu_171_p2;
            end if;
        end if;
    end process;

    ap_NS_fsm_assign_proc : process (ap_start, ap_CS_fsm, ap_CS_fsm_state1, audio_out_V_1_ack_in, ap_CS_fsm_state3, ap_CS_fsm_state4, grp_fm_receiver_fu_122_ap_done)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if (((ap_const_logic_1 = ap_CS_fsm_state1) and (ap_start = ap_const_logic_1))) then
                    ap_NS_fsm <= ap_ST_fsm_state2;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_state2 => 
                ap_NS_fsm <= ap_ST_fsm_state3;
            when ap_ST_fsm_state3 => 
                if ((not(((grp_fm_receiver_fu_122_ap_done = ap_const_logic_0) or (audio_out_V_1_ack_in = ap_const_logic_0))) and (ap_const_logic_1 = ap_CS_fsm_state3))) then
                    ap_NS_fsm <= ap_ST_fsm_state4;
                else
                    ap_NS_fsm <= ap_ST_fsm_state3;
                end if;
            when ap_ST_fsm_state4 => 
                if (((ap_const_logic_1 = ap_CS_fsm_state4) and (audio_out_V_1_ack_in = ap_const_logic_1))) then
                    ap_NS_fsm <= ap_ST_fsm_state1;
                else
                    ap_NS_fsm <= ap_ST_fsm_state4;
                end if;
            when others =>  
                ap_NS_fsm <= "XXXX";
        end case;
    end process;
    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state2 <= ap_CS_fsm(1);
    ap_CS_fsm_state3 <= ap_CS_fsm(2);
    ap_CS_fsm_state4 <= ap_CS_fsm(3);

    ap_done_assign_proc : process(audio_out_V_1_ack_in, ap_CS_fsm_state4)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state4) and (audio_out_V_1_ack_in = ap_const_logic_1))) then 
            ap_done <= ap_const_logic_1;
        else 
            ap_done <= ap_const_logic_0;
        end if; 
    end process;


    ap_idle_assign_proc : process(ap_start, ap_CS_fsm_state1)
    begin
        if (((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1))) then 
            ap_idle <= ap_const_logic_1;
        else 
            ap_idle <= ap_const_logic_0;
        end if; 
    end process;


    ap_ready_assign_proc : process(audio_out_V_1_ack_in, ap_CS_fsm_state4)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state4) and (audio_out_V_1_ack_in = ap_const_logic_1))) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;


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

    audio_out_V_1_vld_in_assign_proc : process(audio_out_V_1_ack_in, ap_CS_fsm_state3, grp_fm_receiver_fu_122_ap_done)
    begin
        if ((not(((grp_fm_receiver_fu_122_ap_done = ap_const_logic_0) or (audio_out_V_1_ack_in = ap_const_logic_0))) and (ap_const_logic_1 = ap_CS_fsm_state3))) then 
            audio_out_V_1_vld_in <= ap_const_logic_1;
        else 
            audio_out_V_1_vld_in <= ap_const_logic_0;
        end if; 
    end process;

    audio_out_V_1_vld_out <= audio_out_V_1_state(0);
    audio_out_V_TDATA <= audio_out_V_1_data_out;

    audio_out_V_TDATA_blk_n_assign_proc : process(audio_out_V_1_state, ap_CS_fsm_state3, ap_CS_fsm_state4)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state4) or (ap_const_logic_1 = ap_CS_fsm_state3))) then 
            audio_out_V_TDATA_blk_n <= audio_out_V_1_state(1);
        else 
            audio_out_V_TDATA_blk_n <= ap_const_logic_1;
        end if; 
    end process;

    audio_out_V_TVALID <= audio_out_V_1_state(0);
    grp_fm_receiver_fu_122_ap_start <= grp_fm_receiver_fu_122_ap_start_reg;
    grp_fm_receiver_fu_122_iq_in_V_TVALID <= iq_in_V_0_state(0);
    iq_in_V_0_ack_in <= iq_in_V_0_state(1);

    iq_in_V_0_ack_out_assign_proc : process(ap_CS_fsm_state3, grp_fm_receiver_fu_122_iq_in_V_TREADY)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            iq_in_V_0_ack_out <= grp_fm_receiver_fu_122_iq_in_V_TREADY;
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
    iq_in_V_TREADY <= iq_in_V_0_state(1);
    
    led_out_proc : process(config_led_ctrl, toggle_assign_fu_171_p2)
    begin
        led_out <= config_led_ctrl;
        led_out(2) <= toggle_assign_fu_171_p2(0);
    end process;

    tmp5_fu_158_p3 <= (grp_fm_receiver_fu_122_ap_return_1 & grp_fm_receiver_fu_122_ap_return_0);
    toggle_assign_fu_171_p2 <= (toggle xor ap_const_lv1_1);
end behav;
