-- ==============================================================
-- File generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2018.2
-- Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
-- 
-- ==============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity fm_receiver_hls_CONFIG_s_axi is
generic (
    C_S_AXI_ADDR_WIDTH    : INTEGER := 6;
    C_S_AXI_DATA_WIDTH    : INTEGER := 32);
port (
    -- axi4 lite slave signals
    ACLK                  :in   STD_LOGIC;
    ARESET                :in   STD_LOGIC;
    ACLK_EN               :in   STD_LOGIC;
    AWADDR                :in   STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    AWVALID               :in   STD_LOGIC;
    AWREADY               :out  STD_LOGIC;
    WDATA                 :in   STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    WSTRB                 :in   STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH/8-1 downto 0);
    WVALID                :in   STD_LOGIC;
    WREADY                :out  STD_LOGIC;
    BRESP                 :out  STD_LOGIC_VECTOR(1 downto 0);
    BVALID                :out  STD_LOGIC;
    BREADY                :in   STD_LOGIC;
    ARADDR                :in   STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    ARVALID               :in   STD_LOGIC;
    ARREADY               :out  STD_LOGIC;
    RDATA                 :out  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    RRESP                 :out  STD_LOGIC_VECTOR(1 downto 0);
    RVALID                :out  STD_LOGIC;
    RREADY                :in   STD_LOGIC;
    -- user signals
    led_ctrl              :out  STD_LOGIC_VECTOR(7 downto 0);
    git_hash_address0     :in   STD_LOGIC_VECTOR(2 downto 0);
    git_hash_ce0          :in   STD_LOGIC;
    git_hash_we0          :in   STD_LOGIC;
    git_hash_d0           :in   STD_LOGIC_VECTOR(7 downto 0);
    build_time_address0   :in   STD_LOGIC_VECTOR(3 downto 0);
    build_time_ce0        :in   STD_LOGIC;
    build_time_we0        :in   STD_LOGIC;
    build_time_d0         :in   STD_LOGIC_VECTOR(7 downto 0)
);
end entity fm_receiver_hls_CONFIG_s_axi;

-- ------------------------Address Info-------------------
-- 0x00 : reserved
-- 0x04 : reserved
-- 0x08 : reserved
-- 0x0c : reserved
-- 0x10 : Data signal of led_ctrl
--        bit 7~0 - led_ctrl[7:0] (Read/Write)
--        others  - reserved
-- 0x14 : reserved
-- 0x18 ~
-- 0x1f : Memory 'git_hash' (8 * 8b)
--        Word n : bit [ 7: 0] - git_hash[4n]
--                 bit [15: 8] - git_hash[4n+1]
--                 bit [23:16] - git_hash[4n+2]
--                 bit [31:24] - git_hash[4n+3]
-- 0x20 ~
-- 0x2f : Memory 'build_time' (13 * 8b)
--        Word n : bit [ 7: 0] - build_time[4n]
--                 bit [15: 8] - build_time[4n+1]
--                 bit [23:16] - build_time[4n+2]
--                 bit [31:24] - build_time[4n+3]
-- (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

architecture behave of fm_receiver_hls_CONFIG_s_axi is
    type states is (wridle, wrdata, wrresp, wrreset, rdidle, rddata, rdreset);  -- read and write fsm states
    signal wstate  : states := wrreset;
    signal rstate  : states := rdreset;
    signal wnext, rnext: states;
    constant ADDR_LED_CTRL_DATA_0 : INTEGER := 16#10#;
    constant ADDR_LED_CTRL_CTRL   : INTEGER := 16#14#;
    constant ADDR_GIT_HASH_BASE   : INTEGER := 16#18#;
    constant ADDR_GIT_HASH_HIGH   : INTEGER := 16#1f#;
    constant ADDR_BUILD_TIME_BASE : INTEGER := 16#20#;
    constant ADDR_BUILD_TIME_HIGH : INTEGER := 16#2f#;
    constant ADDR_BITS         : INTEGER := 6;

    signal waddr               : UNSIGNED(ADDR_BITS-1 downto 0);
    signal wmask               : UNSIGNED(31 downto 0);
    signal aw_hs               : STD_LOGIC;
    signal w_hs                : STD_LOGIC;
    signal rdata_data          : UNSIGNED(31 downto 0);
    signal ar_hs               : STD_LOGIC;
    signal raddr               : UNSIGNED(ADDR_BITS-1 downto 0);
    signal AWREADY_t           : STD_LOGIC;
    signal WREADY_t            : STD_LOGIC;
    signal ARREADY_t           : STD_LOGIC;
    signal RVALID_t            : STD_LOGIC;
    -- internal registers
    signal int_led_ctrl        : UNSIGNED(7 downto 0) := (others => '0');
    -- memory signals
    signal int_git_hash_address0 : UNSIGNED(0 downto 0);
    signal int_git_hash_ce0    : STD_LOGIC;
    signal int_git_hash_we0    : STD_LOGIC;
    signal int_git_hash_be0    : UNSIGNED(3 downto 0);
    signal int_git_hash_d0     : UNSIGNED(31 downto 0);
    signal int_git_hash_q0     : UNSIGNED(31 downto 0);
    signal int_git_hash_address1 : UNSIGNED(0 downto 0);
    signal int_git_hash_ce1    : STD_LOGIC;
    signal int_git_hash_we1    : STD_LOGIC;
    signal int_git_hash_be1    : UNSIGNED(3 downto 0);
    signal int_git_hash_d1     : UNSIGNED(31 downto 0);
    signal int_git_hash_q1     : UNSIGNED(31 downto 0);
    signal int_git_hash_read   : STD_LOGIC;
    signal int_git_hash_write  : STD_LOGIC;
    signal int_git_hash_shift  : UNSIGNED(1 downto 0);
    signal int_build_time_address0 : UNSIGNED(1 downto 0);
    signal int_build_time_ce0  : STD_LOGIC;
    signal int_build_time_we0  : STD_LOGIC;
    signal int_build_time_be0  : UNSIGNED(3 downto 0);
    signal int_build_time_d0   : UNSIGNED(31 downto 0);
    signal int_build_time_q0   : UNSIGNED(31 downto 0);
    signal int_build_time_address1 : UNSIGNED(1 downto 0);
    signal int_build_time_ce1  : STD_LOGIC;
    signal int_build_time_we1  : STD_LOGIC;
    signal int_build_time_be1  : UNSIGNED(3 downto 0);
    signal int_build_time_d1   : UNSIGNED(31 downto 0);
    signal int_build_time_q1   : UNSIGNED(31 downto 0);
    signal int_build_time_read : STD_LOGIC;
    signal int_build_time_write : STD_LOGIC;
    signal int_build_time_shift : UNSIGNED(1 downto 0);

    component fm_receiver_hls_CONFIG_s_axi_ram is
        generic (
            BYTES   : INTEGER :=4;
            DEPTH   : INTEGER :=256;
            AWIDTH  : INTEGER :=8);
        port (
            clk0    : in  STD_LOGIC;
            address0: in  UNSIGNED(AWIDTH-1 downto 0);
            ce0     : in  STD_LOGIC;
            we0     : in  STD_LOGIC;
            be0     : in  UNSIGNED(BYTES-1 downto 0);
            d0      : in  UNSIGNED(BYTES*8-1 downto 0);
            q0      : out UNSIGNED(BYTES*8-1 downto 0);
            clk1    : in  STD_LOGIC;
            address1: in  UNSIGNED(AWIDTH-1 downto 0);
            ce1     : in  STD_LOGIC;
            we1     : in  STD_LOGIC;
            be1     : in  UNSIGNED(BYTES-1 downto 0);
            d1      : in  UNSIGNED(BYTES*8-1 downto 0);
            q1      : out UNSIGNED(BYTES*8-1 downto 0));
    end component fm_receiver_hls_CONFIG_s_axi_ram;

    function log2 (x : INTEGER) return INTEGER is
        variable n, m : INTEGER;
    begin
        n := 1;
        m := 2;
        while m < x loop
            n := n + 1;
            m := m * 2;
        end loop;
        return n;
    end function log2;

begin
-- ----------------------- Instantiation------------------
-- int_git_hash
int_git_hash : fm_receiver_hls_CONFIG_s_axi_ram
generic map (
     BYTES    => 4,
     DEPTH    => 2,
     AWIDTH   => log2(2))
port map (
     clk0     => ACLK,
     address0 => int_git_hash_address0,
     ce0      => int_git_hash_ce0,
     we0      => int_git_hash_we0,
     be0      => int_git_hash_be0,
     d0       => int_git_hash_d0,
     q0       => int_git_hash_q0,
     clk1     => ACLK,
     address1 => int_git_hash_address1,
     ce1      => int_git_hash_ce1,
     we1      => int_git_hash_we1,
     be1      => int_git_hash_be1,
     d1       => int_git_hash_d1,
     q1       => int_git_hash_q1);
-- int_build_time
int_build_time : fm_receiver_hls_CONFIG_s_axi_ram
generic map (
     BYTES    => 4,
     DEPTH    => 4,
     AWIDTH   => log2(4))
port map (
     clk0     => ACLK,
     address0 => int_build_time_address0,
     ce0      => int_build_time_ce0,
     we0      => int_build_time_we0,
     be0      => int_build_time_be0,
     d0       => int_build_time_d0,
     q0       => int_build_time_q0,
     clk1     => ACLK,
     address1 => int_build_time_address1,
     ce1      => int_build_time_ce1,
     we1      => int_build_time_we1,
     be1      => int_build_time_be1,
     d1       => int_build_time_d1,
     q1       => int_build_time_q1);

-- ----------------------- AXI WRITE ---------------------
    AWREADY_t <=  '1' when wstate = wridle else '0';
    AWREADY   <=  AWREADY_t;
    WREADY_t  <=  '1' when wstate = wrdata else '0';
    WREADY    <=  WREADY_t;
    BRESP     <=  "00";  -- OKAY
    BVALID    <=  '1' when wstate = wrresp else '0';
    wmask     <=  (31 downto 24 => WSTRB(3), 23 downto 16 => WSTRB(2), 15 downto 8 => WSTRB(1), 7 downto 0 => WSTRB(0));
    aw_hs     <=  AWVALID and AWREADY_t;
    w_hs      <=  WVALID and WREADY_t;

    -- write FSM
    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                wstate <= wrreset;
            elsif (ACLK_EN = '1') then
                wstate <= wnext;
            end if;
        end if;
    end process;

    process (wstate, AWVALID, WVALID, BREADY)
    begin
        case (wstate) is
        when wridle =>
            if (AWVALID = '1') then
                wnext <= wrdata;
            else
                wnext <= wridle;
            end if;
        when wrdata =>
            if (WVALID = '1') then
                wnext <= wrresp;
            else
                wnext <= wrdata;
            end if;
        when wrresp =>
            if (BREADY = '1') then
                wnext <= wridle;
            else
                wnext <= wrresp;
            end if;
        when others =>
            wnext <= wridle;
        end case;
    end process;

    waddr_proc : process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ACLK_EN = '1') then
                if (aw_hs = '1') then
                    waddr <= UNSIGNED(AWADDR(ADDR_BITS-1 downto 0));
                end if;
            end if;
        end if;
    end process;

-- ----------------------- AXI READ ----------------------
    ARREADY_t <= '1' when (rstate = rdidle) else '0';
    ARREADY <= ARREADY_t;
    RDATA   <= STD_LOGIC_VECTOR(rdata_data);
    RRESP   <= "00";  -- OKAY
    RVALID_t  <= '1' when (rstate = rddata) and (int_git_hash_read = '0') and (int_build_time_read = '0') else '0';
    RVALID    <= RVALID_t;
    ar_hs   <= ARVALID and ARREADY_t;
    raddr   <= UNSIGNED(ARADDR(ADDR_BITS-1 downto 0));

    -- read FSM
    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                rstate <= rdreset;
            elsif (ACLK_EN = '1') then
                rstate <= rnext;
            end if;
        end if;
    end process;

    process (rstate, ARVALID, RREADY, RVALID_t)
    begin
        case (rstate) is
        when rdidle =>
            if (ARVALID = '1') then
                rnext <= rddata;
            else
                rnext <= rdidle;
            end if;
        when rddata =>
            if (RREADY = '1' and RVALID_t = '1') then
                rnext <= rdidle;
            else
                rnext <= rddata;
            end if;
        when others =>
            rnext <= rdidle;
        end case;
    end process;

    rdata_proc : process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ACLK_EN = '1') then
                if (ar_hs = '1') then
                    case (TO_INTEGER(raddr)) is
                    when ADDR_LED_CTRL_DATA_0 =>
                        rdata_data <= RESIZE(int_led_ctrl(7 downto 0), 32);
                    when others =>
                        rdata_data <= (others => '0');
                    end case;
                elsif (int_git_hash_read = '1') then
                    rdata_data <= int_git_hash_q1;
                elsif (int_build_time_read = '1') then
                    rdata_data <= int_build_time_q1;
                end if;
            end if;
        end if;
    end process;

-- ----------------------- Register logic ----------------
    led_ctrl             <= STD_LOGIC_VECTOR(int_led_ctrl);

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ACLK_EN = '1') then
                if (w_hs = '1' and waddr = ADDR_LED_CTRL_DATA_0) then
                    int_led_ctrl(7 downto 0) <= (UNSIGNED(WDATA(7 downto 0)) and wmask(7 downto 0)) or ((not wmask(7 downto 0)) and int_led_ctrl(7 downto 0));
                end if;
            end if;
        end if;
    end process;


-- ----------------------- Memory logic ------------------
    -- git_hash
    int_git_hash_address0 <= SHIFT_RIGHT(UNSIGNED(git_hash_address0), 2)(0 downto 0);
    int_git_hash_ce0     <= git_hash_ce0;
    int_git_hash_we0     <= git_hash_we0;
    int_git_hash_be0     <= SHIFT_LEFT(TO_UNSIGNED(1, 4), TO_INTEGER(UNSIGNED(git_hash_address0(1 downto 0))));
    int_git_hash_d0      <= UNSIGNED(git_hash_d0) & UNSIGNED(git_hash_d0) & UNSIGNED(git_hash_d0) & UNSIGNED(git_hash_d0);
    int_git_hash_address1 <= raddr(2 downto 2) when ar_hs = '1' else waddr(2 downto 2);
    int_git_hash_ce1     <= '1' when ar_hs = '1' or (int_git_hash_write = '1' and WVALID  = '1') else '0';
    int_git_hash_we1     <= '1' when int_git_hash_write = '1' and WVALID = '1' else '0';
    int_git_hash_be1     <= UNSIGNED(WSTRB);
    int_git_hash_d1      <= UNSIGNED(WDATA);
    -- build_time
    int_build_time_address0 <= SHIFT_RIGHT(UNSIGNED(build_time_address0), 2)(1 downto 0);
    int_build_time_ce0   <= build_time_ce0;
    int_build_time_we0   <= build_time_we0;
    int_build_time_be0   <= SHIFT_LEFT(TO_UNSIGNED(1, 4), TO_INTEGER(UNSIGNED(build_time_address0(1 downto 0))));
    int_build_time_d0    <= UNSIGNED(build_time_d0) & UNSIGNED(build_time_d0) & UNSIGNED(build_time_d0) & UNSIGNED(build_time_d0);
    int_build_time_address1 <= raddr(3 downto 2) when ar_hs = '1' else waddr(3 downto 2);
    int_build_time_ce1   <= '1' when ar_hs = '1' or (int_build_time_write = '1' and WVALID  = '1') else '0';
    int_build_time_we1   <= '1' when int_build_time_write = '1' and WVALID = '1' else '0';
    int_build_time_be1   <= UNSIGNED(WSTRB);
    int_build_time_d1    <= UNSIGNED(WDATA);

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_git_hash_read <= '0';
            elsif (ACLK_EN = '1') then
                if (ar_hs = '1' and raddr >= ADDR_GIT_HASH_BASE and raddr <= ADDR_GIT_HASH_HIGH) then
                    int_git_hash_read <= '1';
                else
                    int_git_hash_read <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_git_hash_write <= '0';
            elsif (ACLK_EN = '1') then
                if (aw_hs = '1' and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) >= ADDR_GIT_HASH_BASE and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) <= ADDR_GIT_HASH_HIGH) then
                    int_git_hash_write <= '1';
                elsif (WVALID = '1') then
                    int_git_hash_write <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ACLK_EN = '1') then
                if (git_hash_ce0 = '1') then
                    int_git_hash_shift <= UNSIGNED(git_hash_address0(1 downto 0));
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_build_time_read <= '0';
            elsif (ACLK_EN = '1') then
                if (ar_hs = '1' and raddr >= ADDR_BUILD_TIME_BASE and raddr <= ADDR_BUILD_TIME_HIGH) then
                    int_build_time_read <= '1';
                else
                    int_build_time_read <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ARESET = '1') then
                int_build_time_write <= '0';
            elsif (ACLK_EN = '1') then
                if (aw_hs = '1' and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) >= ADDR_BUILD_TIME_BASE and UNSIGNED(AWADDR(ADDR_BITS-1 downto 0)) <= ADDR_BUILD_TIME_HIGH) then
                    int_build_time_write <= '1';
                elsif (WVALID = '1') then
                    int_build_time_write <= '0';
                end if;
            end if;
        end if;
    end process;

    process (ACLK)
    begin
        if (ACLK'event and ACLK = '1') then
            if (ACLK_EN = '1') then
                if (build_time_ce0 = '1') then
                    int_build_time_shift <= UNSIGNED(build_time_address0(1 downto 0));
                end if;
            end if;
        end if;
    end process;


end architecture behave;

library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity fm_receiver_hls_CONFIG_s_axi_ram is
    generic (
        BYTES   : INTEGER :=4;
        DEPTH   : INTEGER :=256;
        AWIDTH  : INTEGER :=8);
    port (
        clk0    : in  STD_LOGIC;
        address0: in  UNSIGNED(AWIDTH-1 downto 0);
        ce0     : in  STD_LOGIC;
        we0     : in  STD_LOGIC;
        be0     : in  UNSIGNED(BYTES-1 downto 0);
        d0      : in  UNSIGNED(BYTES*8-1 downto 0);
        q0      : out UNSIGNED(BYTES*8-1 downto 0);
        clk1    : in  STD_LOGIC;
        address1: in  UNSIGNED(AWIDTH-1 downto 0);
        ce1     : in  STD_LOGIC;
        we1     : in  STD_LOGIC;
        be1     : in  UNSIGNED(BYTES-1 downto 0);
        d1      : in  UNSIGNED(BYTES*8-1 downto 0);
        q1      : out UNSIGNED(BYTES*8-1 downto 0));

end entity fm_receiver_hls_CONFIG_s_axi_ram;

architecture behave of fm_receiver_hls_CONFIG_s_axi_ram is
    signal address0_tmp : UNSIGNED(AWIDTH-1 downto 0);
    signal address1_tmp : UNSIGNED(AWIDTH-1 downto 0);
    type RAM_T is array (0 to DEPTH - 1) of UNSIGNED(BYTES*8 - 1 downto 0);
    shared variable mem : RAM_T := (others => (others => '0'));
begin

    process (address0)
    begin
    address0_tmp <= address0;
    --synthesis translate_off
          if (address0 > DEPTH-1) then
              address0_tmp <= (others => '0');
          else
              address0_tmp <= address0;
          end if;
    --synthesis translate_on
    end process;

    process (address1)
    begin
    address1_tmp <= address1;
    --synthesis translate_off
          if (address1 > DEPTH-1) then
              address1_tmp <= (others => '0');
          else
              address1_tmp <= address1;
          end if;
    --synthesis translate_on
    end process;

    --read port 0
    process (clk0) begin
        if (clk0'event and clk0 = '1') then
            if (ce0 = '1') then
                q0 <= mem(to_integer(address0_tmp));
            end if;
        end if;
    end process;

    --read port 1
    process (clk1) begin
        if (clk1'event and clk1 = '1') then
            if (ce1 = '1') then
                q1 <= mem(to_integer(address1_tmp));
            end if;
        end if;
    end process;

    gen_write : for i in 0 to BYTES - 1 generate
    begin
        --write port 0
        process (clk0)
        begin
            if (clk0'event and clk0 = '1') then
                if (ce0 = '1' and we0 = '1' and be0(i) = '1') then
                    mem(to_integer(address0_tmp))(8*i+7 downto 8*i) := d0(8*i+7 downto 8*i);
                end if;
            end if;
        end process;

        --write port 1
        process (clk1)
        begin
            if (clk1'event and clk1 = '1') then
                if (ce1 = '1' and we1 = '1' and be1(i) = '1') then
                    mem(to_integer(address1_tmp))(8*i+7 downto 8*i) := d1(8*i+7 downto 8*i);
                end if;
            end if;
        end process;

    end generate;

end architecture behave;


