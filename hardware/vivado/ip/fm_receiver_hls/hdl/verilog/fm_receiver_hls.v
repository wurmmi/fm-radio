// ==============================================================
// RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
// Version: 2018.2
// Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
// 
// ===========================================================

`timescale 1 ns / 1 ps 

(* CORE_GENERATION_INFO="fm_receiver_hls,hls_ip_2018_2,{HLS_INPUT_TYPE=cxx,HLS_INPUT_FLOAT=0,HLS_INPUT_FIXED=0,HLS_INPUT_PART=xc7z020clg484-1,HLS_INPUT_CLOCK=10.000000,HLS_INPUT_ARCH=others,HLS_SYN_CLOCK=1.000000,HLS_SYN_LAT=2,HLS_SYN_TPT=none,HLS_SYN_MEM=2,HLS_SYN_DSP=0,HLS_SYN_FF=272,HLS_SYN_LUT=248,HLS_VERSION=2018_2}" *)

module fm_receiver_hls (
        ap_clk,
        ap_rst_n,
        ap_start,
        ap_done,
        ap_idle,
        ap_ready,
        iq_in_V_TDATA,
        iq_in_V_TVALID,
        iq_in_V_TREADY,
        audio_out_V_TDATA,
        audio_out_V_TVALID,
        audio_out_V_TREADY,
        build_time_address0,
        build_time_ce0,
        build_time_we0,
        build_time_d0,
        build_time_q0,
        build_time_address1,
        build_time_ce1,
        build_time_we1,
        build_time_d1,
        build_time_q1,
        led_out,
        s_axi_CONFIG_AWVALID,
        s_axi_CONFIG_AWREADY,
        s_axi_CONFIG_AWADDR,
        s_axi_CONFIG_WVALID,
        s_axi_CONFIG_WREADY,
        s_axi_CONFIG_WDATA,
        s_axi_CONFIG_WSTRB,
        s_axi_CONFIG_ARVALID,
        s_axi_CONFIG_ARREADY,
        s_axi_CONFIG_ARADDR,
        s_axi_CONFIG_RVALID,
        s_axi_CONFIG_RREADY,
        s_axi_CONFIG_RDATA,
        s_axi_CONFIG_RRESP,
        s_axi_CONFIG_BVALID,
        s_axi_CONFIG_BREADY,
        s_axi_CONFIG_BRESP
);

parameter    ap_ST_fsm_state1 = 3'd1;
parameter    ap_ST_fsm_state2 = 3'd2;
parameter    ap_ST_fsm_state3 = 3'd4;
parameter    C_S_AXI_CONFIG_DATA_WIDTH = 32;
parameter    C_S_AXI_CONFIG_ADDR_WIDTH = 5;
parameter    C_S_AXI_DATA_WIDTH = 32;

parameter C_S_AXI_CONFIG_WSTRB_WIDTH = (32 / 8);
parameter C_S_AXI_WSTRB_WIDTH = (32 / 8);

input   ap_clk;
input   ap_rst_n;
input   ap_start;
output   ap_done;
output   ap_idle;
output   ap_ready;
input  [31:0] iq_in_V_TDATA;
input   iq_in_V_TVALID;
output   iq_in_V_TREADY;
output  [31:0] audio_out_V_TDATA;
output   audio_out_V_TVALID;
input   audio_out_V_TREADY;
output  [3:0] build_time_address0;
output   build_time_ce0;
output   build_time_we0;
output  [7:0] build_time_d0;
input  [7:0] build_time_q0;
output  [3:0] build_time_address1;
output   build_time_ce1;
output   build_time_we1;
output  [7:0] build_time_d1;
input  [7:0] build_time_q1;
output  [7:0] led_out;
input   s_axi_CONFIG_AWVALID;
output   s_axi_CONFIG_AWREADY;
input  [C_S_AXI_CONFIG_ADDR_WIDTH - 1:0] s_axi_CONFIG_AWADDR;
input   s_axi_CONFIG_WVALID;
output   s_axi_CONFIG_WREADY;
input  [C_S_AXI_CONFIG_DATA_WIDTH - 1:0] s_axi_CONFIG_WDATA;
input  [C_S_AXI_CONFIG_WSTRB_WIDTH - 1:0] s_axi_CONFIG_WSTRB;
input   s_axi_CONFIG_ARVALID;
output   s_axi_CONFIG_ARREADY;
input  [C_S_AXI_CONFIG_ADDR_WIDTH - 1:0] s_axi_CONFIG_ARADDR;
output   s_axi_CONFIG_RVALID;
input   s_axi_CONFIG_RREADY;
output  [C_S_AXI_CONFIG_DATA_WIDTH - 1:0] s_axi_CONFIG_RDATA;
output  [1:0] s_axi_CONFIG_RRESP;
output   s_axi_CONFIG_BVALID;
input   s_axi_CONFIG_BREADY;
output  [1:0] s_axi_CONFIG_BRESP;

reg ap_done;
reg ap_idle;
reg ap_ready;
reg[7:0] led_out;

 reg    ap_rst_n_inv;
(* fsm_encoding = "none" *) reg   [2:0] ap_CS_fsm;
wire    ap_CS_fsm_state1;
reg   [31:0] iq_in_V_0_data_out;
wire    iq_in_V_0_vld_in;
wire    iq_in_V_0_vld_out;
wire    iq_in_V_0_ack_in;
reg    iq_in_V_0_ack_out;
reg   [31:0] iq_in_V_0_payload_A;
reg   [31:0] iq_in_V_0_payload_B;
reg    iq_in_V_0_sel_rd;
reg    iq_in_V_0_sel_wr;
wire    iq_in_V_0_sel;
wire    iq_in_V_0_load_A;
wire    iq_in_V_0_load_B;
reg   [1:0] iq_in_V_0_state;
wire    iq_in_V_0_state_cmp_full;
reg   [31:0] audio_out_V_1_data_out;
reg    audio_out_V_1_vld_in;
wire    audio_out_V_1_vld_out;
wire    audio_out_V_1_ack_in;
wire    audio_out_V_1_ack_out;
reg   [31:0] audio_out_V_1_payload_A;
reg   [31:0] audio_out_V_1_payload_B;
reg    audio_out_V_1_sel_rd;
reg    audio_out_V_1_sel_wr;
wire    audio_out_V_1_sel;
wire    audio_out_V_1_load_A;
wire    audio_out_V_1_load_B;
reg   [1:0] audio_out_V_1_state;
wire    audio_out_V_1_state_cmp_full;
wire   [7:0] led_ctrl;
reg   [0:0] toggle;
reg    iq_in_V_TDATA_blk_n;
wire    ap_CS_fsm_state2;
reg    audio_out_V_TDATA_blk_n;
wire    ap_CS_fsm_state3;
wire   [0:0] tmp_4_fu_90_p2;
reg   [7:0] led_out_preg;
reg   [2:0] ap_NS_fsm;

// power-on initialization
initial begin
#0 ap_CS_fsm = 3'd1;
#0 iq_in_V_0_sel_rd = 1'b0;
#0 iq_in_V_0_sel_wr = 1'b0;
#0 iq_in_V_0_state = 2'd0;
#0 audio_out_V_1_sel_rd = 1'b0;
#0 audio_out_V_1_sel_wr = 1'b0;
#0 audio_out_V_1_state = 2'd0;
#0 toggle = 1'd0;
#0 led_out_preg = 8'd0;
end

fm_receiver_hls_CONFIG_s_axi #(
    .C_S_AXI_ADDR_WIDTH( C_S_AXI_CONFIG_ADDR_WIDTH ),
    .C_S_AXI_DATA_WIDTH( C_S_AXI_CONFIG_DATA_WIDTH ))
fm_receiver_hls_CONFIG_s_axi_U(
    .AWVALID(s_axi_CONFIG_AWVALID),
    .AWREADY(s_axi_CONFIG_AWREADY),
    .AWADDR(s_axi_CONFIG_AWADDR),
    .WVALID(s_axi_CONFIG_WVALID),
    .WREADY(s_axi_CONFIG_WREADY),
    .WDATA(s_axi_CONFIG_WDATA),
    .WSTRB(s_axi_CONFIG_WSTRB),
    .ARVALID(s_axi_CONFIG_ARVALID),
    .ARREADY(s_axi_CONFIG_ARREADY),
    .ARADDR(s_axi_CONFIG_ARADDR),
    .RVALID(s_axi_CONFIG_RVALID),
    .RREADY(s_axi_CONFIG_RREADY),
    .RDATA(s_axi_CONFIG_RDATA),
    .RRESP(s_axi_CONFIG_RRESP),
    .BVALID(s_axi_CONFIG_BVALID),
    .BREADY(s_axi_CONFIG_BREADY),
    .BRESP(s_axi_CONFIG_BRESP),
    .ACLK(ap_clk),
    .ARESET(ap_rst_n_inv),
    .ACLK_EN(1'b1),
    .led_ctrl(led_ctrl)
);

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        ap_CS_fsm <= ap_ST_fsm_state1;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        audio_out_V_1_sel_rd <= 1'b0;
    end else begin
        if (((audio_out_V_1_vld_out == 1'b1) & (audio_out_V_1_ack_out == 1'b1))) begin
            audio_out_V_1_sel_rd <= ~audio_out_V_1_sel_rd;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        audio_out_V_1_sel_wr <= 1'b0;
    end else begin
        if (((audio_out_V_1_vld_in == 1'b1) & (audio_out_V_1_ack_in == 1'b1))) begin
            audio_out_V_1_sel_wr <= ~audio_out_V_1_sel_wr;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        audio_out_V_1_state <= 2'd0;
    end else begin
        if ((((audio_out_V_1_state == 2'd2) & (audio_out_V_1_vld_in == 1'b0)) | ((audio_out_V_1_state == 2'd3) & (audio_out_V_1_vld_in == 1'b0) & (audio_out_V_1_ack_out == 1'b1)))) begin
            audio_out_V_1_state <= 2'd2;
        end else if ((((audio_out_V_1_state == 2'd1) & (audio_out_V_1_ack_out == 1'b0)) | ((audio_out_V_1_state == 2'd3) & (audio_out_V_1_ack_out == 1'b0) & (audio_out_V_1_vld_in == 1'b1)))) begin
            audio_out_V_1_state <= 2'd1;
        end else if (((~((audio_out_V_1_vld_in == 1'b0) & (audio_out_V_1_ack_out == 1'b1)) & ~((audio_out_V_1_ack_out == 1'b0) & (audio_out_V_1_vld_in == 1'b1)) & (audio_out_V_1_state == 2'd3)) | ((audio_out_V_1_state == 2'd1) & (audio_out_V_1_ack_out == 1'b1)) | ((audio_out_V_1_state == 2'd2) & (audio_out_V_1_vld_in == 1'b1)))) begin
            audio_out_V_1_state <= 2'd3;
        end else begin
            audio_out_V_1_state <= 2'd2;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        iq_in_V_0_sel_rd <= 1'b0;
    end else begin
        if (((iq_in_V_0_ack_out == 1'b1) & (iq_in_V_0_vld_out == 1'b1))) begin
            iq_in_V_0_sel_rd <= ~iq_in_V_0_sel_rd;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        iq_in_V_0_sel_wr <= 1'b0;
    end else begin
        if (((iq_in_V_0_ack_in == 1'b1) & (iq_in_V_0_vld_in == 1'b1))) begin
            iq_in_V_0_sel_wr <= ~iq_in_V_0_sel_wr;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        iq_in_V_0_state <= 2'd0;
    end else begin
        if ((((iq_in_V_0_state == 2'd2) & (iq_in_V_0_vld_in == 1'b0)) | ((iq_in_V_0_state == 2'd3) & (iq_in_V_0_vld_in == 1'b0) & (iq_in_V_0_ack_out == 1'b1)))) begin
            iq_in_V_0_state <= 2'd2;
        end else if ((((iq_in_V_0_state == 2'd1) & (iq_in_V_0_ack_out == 1'b0)) | ((iq_in_V_0_state == 2'd3) & (iq_in_V_0_ack_out == 1'b0) & (iq_in_V_0_vld_in == 1'b1)))) begin
            iq_in_V_0_state <= 2'd1;
        end else if (((~((iq_in_V_0_vld_in == 1'b0) & (iq_in_V_0_ack_out == 1'b1)) & ~((iq_in_V_0_ack_out == 1'b0) & (iq_in_V_0_vld_in == 1'b1)) & (iq_in_V_0_state == 2'd3)) | ((iq_in_V_0_state == 2'd1) & (iq_in_V_0_ack_out == 1'b1)) | ((iq_in_V_0_state == 2'd2) & (iq_in_V_0_vld_in == 1'b1)))) begin
            iq_in_V_0_state <= 2'd3;
        end else begin
            iq_in_V_0_state <= 2'd2;
        end
    end
end

always @ (posedge ap_clk) begin
    if (ap_rst_n_inv == 1'b1) begin
        led_out_preg <= 8'd0;
    end else begin
        if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
            led_out_preg <= led_ctrl;
        end
    end
end

always @ (posedge ap_clk) begin
    if ((audio_out_V_1_load_A == 1'b1)) begin
        audio_out_V_1_payload_A <= iq_in_V_0_data_out;
    end
end

always @ (posedge ap_clk) begin
    if ((audio_out_V_1_load_B == 1'b1)) begin
        audio_out_V_1_payload_B <= iq_in_V_0_data_out;
    end
end

always @ (posedge ap_clk) begin
    if ((iq_in_V_0_load_A == 1'b1)) begin
        iq_in_V_0_payload_A <= iq_in_V_TDATA;
    end
end

always @ (posedge ap_clk) begin
    if ((iq_in_V_0_load_B == 1'b1)) begin
        iq_in_V_0_payload_B <= iq_in_V_TDATA;
    end
end

always @ (posedge ap_clk) begin
    if (((1'b1 == ap_CS_fsm_state3) & (audio_out_V_1_ack_in == 1'b1))) begin
        toggle <= tmp_4_fu_90_p2;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state3) & (audio_out_V_1_ack_in == 1'b1))) begin
        ap_done = 1'b1;
    end else begin
        ap_done = 1'b0;
    end
end

always @ (*) begin
    if (((ap_start == 1'b0) & (1'b1 == ap_CS_fsm_state1))) begin
        ap_idle = 1'b1;
    end else begin
        ap_idle = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state3) & (audio_out_V_1_ack_in == 1'b1))) begin
        ap_ready = 1'b1;
    end else begin
        ap_ready = 1'b0;
    end
end

always @ (*) begin
    if ((audio_out_V_1_sel == 1'b1)) begin
        audio_out_V_1_data_out = audio_out_V_1_payload_B;
    end else begin
        audio_out_V_1_data_out = audio_out_V_1_payload_A;
    end
end

always @ (*) begin
    if ((~((iq_in_V_0_vld_out == 1'b0) | (audio_out_V_1_ack_in == 1'b0)) & (1'b1 == ap_CS_fsm_state2))) begin
        audio_out_V_1_vld_in = 1'b1;
    end else begin
        audio_out_V_1_vld_in = 1'b0;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state3) | (1'b1 == ap_CS_fsm_state2))) begin
        audio_out_V_TDATA_blk_n = audio_out_V_1_state[1'd1];
    end else begin
        audio_out_V_TDATA_blk_n = 1'b1;
    end
end

always @ (*) begin
    if ((~((iq_in_V_0_vld_out == 1'b0) | (audio_out_V_1_ack_in == 1'b0)) & (1'b1 == ap_CS_fsm_state2))) begin
        iq_in_V_0_ack_out = 1'b1;
    end else begin
        iq_in_V_0_ack_out = 1'b0;
    end
end

always @ (*) begin
    if ((iq_in_V_0_sel == 1'b1)) begin
        iq_in_V_0_data_out = iq_in_V_0_payload_B;
    end else begin
        iq_in_V_0_data_out = iq_in_V_0_payload_A;
    end
end

always @ (*) begin
    if ((1'b1 == ap_CS_fsm_state2)) begin
        iq_in_V_TDATA_blk_n = iq_in_V_0_state[1'd0];
    end else begin
        iq_in_V_TDATA_blk_n = 1'b1;
    end
end

always @ (*) begin
    if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
        led_out = led_ctrl;
    end else begin
        led_out = led_out_preg;
    end
end

always @ (*) begin
    case (ap_CS_fsm)
        ap_ST_fsm_state1 : begin
            if (((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end
        end
        ap_ST_fsm_state2 : begin
            if ((~((iq_in_V_0_vld_out == 1'b0) | (audio_out_V_1_ack_in == 1'b0)) & (1'b1 == ap_CS_fsm_state2))) begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state2;
            end
        end
        ap_ST_fsm_state3 : begin
            if (((1'b1 == ap_CS_fsm_state3) & (audio_out_V_1_ack_in == 1'b1))) begin
                ap_NS_fsm = ap_ST_fsm_state1;
            end else begin
                ap_NS_fsm = ap_ST_fsm_state3;
            end
        end
        default : begin
            ap_NS_fsm = 'bx;
        end
    endcase
end

assign ap_CS_fsm_state1 = ap_CS_fsm[32'd0];

assign ap_CS_fsm_state2 = ap_CS_fsm[32'd1];

assign ap_CS_fsm_state3 = ap_CS_fsm[32'd2];

always @ (*) begin
    ap_rst_n_inv = ~ap_rst_n;
end

assign audio_out_V_1_ack_in = audio_out_V_1_state[1'd1];

assign audio_out_V_1_ack_out = audio_out_V_TREADY;

assign audio_out_V_1_load_A = (~audio_out_V_1_sel_wr & audio_out_V_1_state_cmp_full);

assign audio_out_V_1_load_B = (audio_out_V_1_state_cmp_full & audio_out_V_1_sel_wr);

assign audio_out_V_1_sel = audio_out_V_1_sel_rd;

assign audio_out_V_1_state_cmp_full = ((audio_out_V_1_state != 2'd1) ? 1'b1 : 1'b0);

assign audio_out_V_1_vld_out = audio_out_V_1_state[1'd0];

assign audio_out_V_TDATA = audio_out_V_1_data_out;

assign audio_out_V_TVALID = audio_out_V_1_state[1'd0];

assign build_time_address0 = 4'd0;

assign build_time_address1 = 4'd0;

assign build_time_ce0 = 1'b0;

assign build_time_ce1 = 1'b0;

assign build_time_d0 = 8'd0;

assign build_time_d1 = 8'd0;

assign build_time_we0 = 1'b0;

assign build_time_we1 = 1'b0;

assign iq_in_V_0_ack_in = iq_in_V_0_state[1'd1];

assign iq_in_V_0_load_A = (iq_in_V_0_state_cmp_full & ~iq_in_V_0_sel_wr);

assign iq_in_V_0_load_B = (iq_in_V_0_state_cmp_full & iq_in_V_0_sel_wr);

assign iq_in_V_0_sel = iq_in_V_0_sel_rd;

assign iq_in_V_0_state_cmp_full = ((iq_in_V_0_state != 2'd1) ? 1'b1 : 1'b0);

assign iq_in_V_0_vld_in = iq_in_V_TVALID;

assign iq_in_V_0_vld_out = iq_in_V_0_state[1'd0];

assign iq_in_V_TREADY = iq_in_V_0_state[1'd1];

assign tmp_4_fu_90_p2 = (toggle ^ 1'd1);

endmodule //fm_receiver_hls
