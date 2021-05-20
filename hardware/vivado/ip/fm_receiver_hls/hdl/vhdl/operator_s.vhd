-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2018.2
-- Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity operator_s is
port (
    ap_clk : IN STD_LOGIC;
    ap_rst : IN STD_LOGIC;
    ap_start : IN STD_LOGIC;
    ap_done : OUT STD_LOGIC;
    ap_idle : OUT STD_LOGIC;
    ap_ready : OUT STD_LOGIC;
    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_address0 : OUT STD_LOGIC_VECTOR (6 downto 0);
    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_ce0 : OUT STD_LOGIC;
    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_we0 : OUT STD_LOGIC;
    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_d0 : OUT STD_LOGIC_VECTOR (15 downto 0);
    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
    x_V : IN STD_LOGIC_VECTOR (15 downto 0);
    coeff_V_address0 : OUT STD_LOGIC_VECTOR (6 downto 0);
    coeff_V_ce0 : OUT STD_LOGIC;
    coeff_V_q0 : IN STD_LOGIC_VECTOR (15 downto 0);
    ap_return : OUT STD_LOGIC_VECTOR (15 downto 0) );
end;


architecture behav of operator_s is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_logic_0 : STD_LOGIC := '0';
    constant ap_ST_fsm_state1 : STD_LOGIC_VECTOR (4 downto 0) := "00001";
    constant ap_ST_fsm_state2 : STD_LOGIC_VECTOR (4 downto 0) := "00010";
    constant ap_ST_fsm_state3 : STD_LOGIC_VECTOR (4 downto 0) := "00100";
    constant ap_ST_fsm_state4 : STD_LOGIC_VECTOR (4 downto 0) := "01000";
    constant ap_ST_fsm_state5 : STD_LOGIC_VECTOR (4 downto 0) := "10000";
    constant ap_const_lv32_0 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000000";
    constant ap_const_lv32_1 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000001";
    constant ap_const_lv1_0 : STD_LOGIC_VECTOR (0 downto 0) := "0";
    constant ap_const_lv32_2 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000010";
    constant ap_const_lv32_3 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000011";
    constant ap_const_lv32_4 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000100";
    constant ap_const_lv16_0 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
    constant ap_const_lv8_48 : STD_LOGIC_VECTOR (7 downto 0) := "01001000";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv64_0 : STD_LOGIC_VECTOR (63 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000";
    constant ap_const_lv8_FF : STD_LOGIC_VECTOR (7 downto 0) := "11111111";
    constant ap_const_lv32_7 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000111";
    constant ap_const_lv8_0 : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    constant ap_const_lv14_0 : STD_LOGIC_VECTOR (13 downto 0) := "00000000000000";
    constant ap_const_lv32_E : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000001110";
    constant ap_const_lv32_1D : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000011101";
    constant ap_const_boolean_1 : BOOLEAN := true;

    signal ap_CS_fsm : STD_LOGIC_VECTOR (4 downto 0) := "00001";
    attribute fsm_encoding : string;
    attribute fsm_encoding of ap_CS_fsm : signal is "none";
    signal ap_CS_fsm_state1 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state1 : signal is "none";
    signal i_cast_fu_130_p1 : STD_LOGIC_VECTOR (31 downto 0);
    signal i_cast_reg_211 : STD_LOGIC_VECTOR (31 downto 0);
    signal ap_CS_fsm_state2 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state2 : signal is "none";
    signal tmp_s_fu_142_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_s_reg_220 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_fu_134_p3 : STD_LOGIC_VECTOR (0 downto 0);
    signal ap_CS_fsm_state3 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state3 : signal is "none";
    signal grp_fu_123_p2 : STD_LOGIC_VECTOR (7 downto 0);
    signal i_1_reg_242 : STD_LOGIC_VECTOR (7 downto 0);
    signal coeff_V_load_reg_247 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_CS_fsm_state4 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state4 : signal is "none";
    signal ap_CS_fsm_state5 : STD_LOGIC;
    attribute fsm_encoding of ap_CS_fsm_state5 : signal is "none";
    signal p_Val2_s_reg_89 : STD_LOGIC_VECTOR (15 downto 0);
    signal ap_phi_mux_i_phi_fu_105_p4 : STD_LOGIC_VECTOR (7 downto 0);
    signal i_reg_101 : STD_LOGIC_VECTOR (7 downto 0);
    signal p_s_reg_113 : STD_LOGIC_VECTOR (15 downto 0);
    signal tmp_2_fu_148_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal tmp_4_fu_159_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal tmp_3_fu_153_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_5_fu_163_p1 : STD_LOGIC_VECTOR (63 downto 0);
    signal grp_fu_123_p0 : STD_LOGIC_VECTOR (7 downto 0);
    signal grp_fu_191_p3 : STD_LOGIC_VECTOR (29 downto 0);
    signal grp_fu_191_p2 : STD_LOGIC_VECTOR (29 downto 0);
    signal ap_return_preg : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
    signal ap_NS_fsm : STD_LOGIC_VECTOR (4 downto 0);

    component fm_receiver_top_mbkb IS
    generic (
        ID : INTEGER;
        NUM_STAGE : INTEGER;
        din0_WIDTH : INTEGER;
        din1_WIDTH : INTEGER;
        din2_WIDTH : INTEGER;
        dout_WIDTH : INTEGER );
    port (
        din0 : IN STD_LOGIC_VECTOR (15 downto 0);
        din1 : IN STD_LOGIC_VECTOR (15 downto 0);
        din2 : IN STD_LOGIC_VECTOR (29 downto 0);
        dout : OUT STD_LOGIC_VECTOR (29 downto 0) );
    end component;



begin
    fm_receiver_top_mbkb_U1 : component fm_receiver_top_mbkb
    generic map (
        ID => 1,
        NUM_STAGE => 1,
        din0_WIDTH => 16,
        din1_WIDTH => 16,
        din2_WIDTH => 30,
        dout_WIDTH => 30)
    port map (
        din0 => coeff_V_load_reg_247,
        din1 => p_s_reg_113,
        din2 => grp_fu_191_p2,
        dout => grp_fu_191_p3);





    ap_CS_fsm_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_CS_fsm <= ap_ST_fsm_state1;
            else
                ap_CS_fsm <= ap_NS_fsm;
            end if;
        end if;
    end process;


    ap_return_preg_assign_proc : process(ap_clk)
    begin
        if (ap_clk'event and ap_clk =  '1') then
            if (ap_rst = '1') then
                ap_return_preg <= ap_const_lv16_0;
            else
                if (((tmp_fu_134_p3 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
                    ap_return_preg <= p_Val2_s_reg_89;
                end if; 
            end if;
        end if;
    end process;


    i_reg_101_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_logic_1 = ap_CS_fsm_state5)) then 
                i_reg_101 <= i_1_reg_242;
            elsif (((ap_const_logic_1 = ap_CS_fsm_state1) and (ap_start = ap_const_logic_1))) then 
                i_reg_101 <= ap_const_lv8_48;
            end if; 
        end if;
    end process;

    p_Val2_s_reg_89_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_logic_1 = ap_CS_fsm_state5)) then 
                p_Val2_s_reg_89 <= grp_fu_191_p3(29 downto 14);
            elsif (((ap_const_logic_1 = ap_CS_fsm_state1) and (ap_start = ap_const_logic_1))) then 
                p_Val2_s_reg_89 <= ap_const_lv16_0;
            end if; 
        end if;
    end process;

    p_s_reg_113_assign_proc : process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((tmp_s_reg_220 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_state3))) then 
                p_s_reg_113 <= FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_q0;
            elsif (((tmp_fu_134_p3 = ap_const_lv1_0) and (tmp_s_fu_142_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
                p_s_reg_113 <= x_V;
            end if; 
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_logic_1 = ap_CS_fsm_state4)) then
                coeff_V_load_reg_247 <= coeff_V_q0;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_logic_1 = ap_CS_fsm_state3)) then
                i_1_reg_242 <= grp_fu_123_p2;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if ((ap_const_logic_1 = ap_CS_fsm_state2)) then
                i_cast_reg_211 <= i_cast_fu_130_p1;
            end if;
        end if;
    end process;
    process (ap_clk)
    begin
        if (ap_clk'event and ap_clk = '1') then
            if (((tmp_fu_134_p3 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_state2))) then
                tmp_s_reg_220 <= tmp_s_fu_142_p2;
            end if;
        end if;
    end process;

    ap_NS_fsm_assign_proc : process (ap_start, ap_CS_fsm, ap_CS_fsm_state1, ap_CS_fsm_state2, tmp_fu_134_p3)
    begin
        case ap_CS_fsm is
            when ap_ST_fsm_state1 => 
                if (((ap_const_logic_1 = ap_CS_fsm_state1) and (ap_start = ap_const_logic_1))) then
                    ap_NS_fsm <= ap_ST_fsm_state2;
                else
                    ap_NS_fsm <= ap_ST_fsm_state1;
                end if;
            when ap_ST_fsm_state2 => 
                if (((tmp_fu_134_p3 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then
                    ap_NS_fsm <= ap_ST_fsm_state1;
                else
                    ap_NS_fsm <= ap_ST_fsm_state3;
                end if;
            when ap_ST_fsm_state3 => 
                ap_NS_fsm <= ap_ST_fsm_state4;
            when ap_ST_fsm_state4 => 
                ap_NS_fsm <= ap_ST_fsm_state5;
            when ap_ST_fsm_state5 => 
                ap_NS_fsm <= ap_ST_fsm_state2;
            when others =>  
                ap_NS_fsm <= "XXXXX";
        end case;
    end process;

    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_address0_assign_proc : process(ap_CS_fsm_state2, tmp_s_fu_142_p2, tmp_fu_134_p3, ap_CS_fsm_state3, tmp_2_fu_148_p1, tmp_4_fu_159_p1)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_address0 <= tmp_4_fu_159_p1(7 - 1 downto 0);
        elsif (((tmp_fu_134_p3 = ap_const_lv1_0) and (tmp_s_fu_142_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_address0 <= ap_const_lv64_0(7 - 1 downto 0);
        elsif (((tmp_fu_134_p3 = ap_const_lv1_0) and (tmp_s_fu_142_p2 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_address0 <= tmp_2_fu_148_p1(7 - 1 downto 0);
        else 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_address0 <= "XXXXXXX";
        end if; 
    end process;


    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_ce0_assign_proc : process(ap_CS_fsm_state2, tmp_s_fu_142_p2, tmp_fu_134_p3, ap_CS_fsm_state3)
    begin
        if (((ap_const_logic_1 = ap_CS_fsm_state3) or ((tmp_fu_134_p3 = ap_const_lv1_0) and (tmp_s_fu_142_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2)) or ((tmp_fu_134_p3 = ap_const_lv1_0) and (tmp_s_fu_142_p2 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_state2)))) then 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_ce0 <= ap_const_logic_1;
        else 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_ce0 <= ap_const_logic_0;
        end if; 
    end process;


    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_d0_assign_proc : process(FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_q0, x_V, ap_CS_fsm_state2, tmp_s_fu_142_p2, tmp_fu_134_p3, ap_CS_fsm_state3)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_d0 <= FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_q0;
        elsif (((tmp_fu_134_p3 = ap_const_lv1_0) and (tmp_s_fu_142_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_d0 <= x_V;
        else 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_d0 <= "XXXXXXXXXXXXXXXX";
        end if; 
    end process;


    FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_we0_assign_proc : process(ap_CS_fsm_state2, tmp_s_fu_142_p2, tmp_s_reg_220, tmp_fu_134_p3, ap_CS_fsm_state3, tmp_3_fu_153_p2)
    begin
        if ((((tmp_3_fu_153_p2 = ap_const_lv1_0) and (tmp_s_reg_220 = ap_const_lv1_0) and (ap_const_logic_1 = ap_CS_fsm_state3)) or ((tmp_fu_134_p3 = ap_const_lv1_0) and (tmp_s_fu_142_p2 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2)))) then 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_we0 <= ap_const_logic_1;
        else 
            FIR_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_ap_fixed_16_2_5_3_0_I_shift_reg_V_we0 <= ap_const_logic_0;
        end if; 
    end process;

    ap_CS_fsm_state1 <= ap_CS_fsm(0);
    ap_CS_fsm_state2 <= ap_CS_fsm(1);
    ap_CS_fsm_state3 <= ap_CS_fsm(2);
    ap_CS_fsm_state4 <= ap_CS_fsm(3);
    ap_CS_fsm_state5 <= ap_CS_fsm(4);

    ap_done_assign_proc : process(ap_start, ap_CS_fsm_state1, ap_CS_fsm_state2, tmp_fu_134_p3)
    begin
        if ((((tmp_fu_134_p3 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2)) or ((ap_start = ap_const_logic_0) and (ap_const_logic_1 = ap_CS_fsm_state1)))) then 
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

    ap_phi_mux_i_phi_fu_105_p4 <= i_reg_101;

    ap_ready_assign_proc : process(ap_CS_fsm_state2, tmp_fu_134_p3)
    begin
        if (((tmp_fu_134_p3 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            ap_ready <= ap_const_logic_1;
        else 
            ap_ready <= ap_const_logic_0;
        end if; 
    end process;


    ap_return_assign_proc : process(ap_CS_fsm_state2, tmp_fu_134_p3, p_Val2_s_reg_89, ap_return_preg)
    begin
        if (((tmp_fu_134_p3 = ap_const_lv1_1) and (ap_const_logic_1 = ap_CS_fsm_state2))) then 
            ap_return <= p_Val2_s_reg_89;
        else 
            ap_return <= ap_return_preg;
        end if; 
    end process;

    coeff_V_address0 <= tmp_5_fu_163_p1(7 - 1 downto 0);

    coeff_V_ce0_assign_proc : process(ap_CS_fsm_state3)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            coeff_V_ce0 <= ap_const_logic_1;
        else 
            coeff_V_ce0 <= ap_const_logic_0;
        end if; 
    end process;


    grp_fu_123_p0_assign_proc : process(ap_CS_fsm_state2, ap_CS_fsm_state3, ap_phi_mux_i_phi_fu_105_p4, i_reg_101)
    begin
        if ((ap_const_logic_1 = ap_CS_fsm_state3)) then 
            grp_fu_123_p0 <= i_reg_101;
        elsif ((ap_const_logic_1 = ap_CS_fsm_state2)) then 
            grp_fu_123_p0 <= ap_phi_mux_i_phi_fu_105_p4;
        else 
            grp_fu_123_p0 <= "XXXXXXXX";
        end if; 
    end process;

    grp_fu_123_p2 <= std_logic_vector(signed(grp_fu_123_p0) + signed(ap_const_lv8_FF));
    grp_fu_191_p2 <= (p_Val2_s_reg_89 & ap_const_lv14_0);
        i_cast_fu_130_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(i_reg_101),32));

    tmp_2_fu_148_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(grp_fu_123_p2),64));
    tmp_3_fu_153_p2 <= "1" when (i_reg_101 = ap_const_lv8_48) else "0";
    tmp_4_fu_159_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(i_cast_reg_211),64));
    tmp_5_fu_163_p1 <= std_logic_vector(IEEE.numeric_std.resize(unsigned(i_cast_reg_211),64));
    tmp_fu_134_p3 <= i_reg_101(7 downto 7);
    tmp_s_fu_142_p2 <= "1" when (i_reg_101 = ap_const_lv8_0) else "0";
end behav;
