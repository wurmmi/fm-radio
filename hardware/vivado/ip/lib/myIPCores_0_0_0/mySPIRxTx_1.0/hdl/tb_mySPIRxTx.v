`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2017 23:22:03
// Design Name: 
// Module Name: tb_mySPI_AXIS
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_mySPIRxTx();
    wire sclk;
    wire mosi;
    wire miso;
    wire ss;
    
    reg axis_aclk = 0;
    reg axis_aresetn = 0;
    wire s00_axis_tready;
    reg [31:0]s00_axis_tdata=0;
    reg s00_axis_tstrb=0;
    reg s00_axis_tlast=0;
    reg s00_axis_tvalid=0; 

    wire m00_axis_tvalid;
    wire [31:0]m00_axis_tdata;
    wire m00_axis_tstrb;
    wire m00_axis_tlast;
    reg m00_axis_tready = 1;

	mySPIRxTx_v1_0 # (
        .width(8),
        .clkdiv(2),
        .sspol(1),
		.C_S00_AXIS_TDATA_WIDTH(32),
		.C_M00_AXIS_TDATA_WIDTH(32)
	) mySPIRxTx_v1_0_inst (
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss(ss),
		.axis_aclk(axis_aclk),
		.axis_aresetn(axis_aresetn),
		.s00_axis_tready(s00_axis_tready),
		.s00_axis_tdata(s00_axis_tdata),
		.s00_axis_tstrb(s00_axis_tstrb),
		.s00_axis_tlast(s00_axis_tlast),
		.s00_axis_tvalid(s00_axis_tvalid),
		.m00_axis_tvalid(m00_axis_tvalid),
		.m00_axis_tdata(m00_axis_tdata),
		.m00_axis_tstrb(m00_axis_tstrb),
		.m00_axis_tlast(m00_axis_tlast),
		.m00_axis_tready(m00_axis_tready)
	);
	
	assign miso = mosi; // Loop back mosi to miso

    always begin
        #1 axis_aclk=~axis_aclk;
    end   

    initial begin
        #20;
        @ (posedge axis_aclk) s00_axis_tdata = 16'hAAAA;s00_axis_tvalid = 1;s00_axis_tlast = 0;
        while (s00_axis_tready==0) begin
            @ (posedge axis_aclk) ;
        end
        @ (posedge axis_aclk) s00_axis_tdata = 16'h5555;s00_axis_tvalid = 1;s00_axis_tlast = 1;
        while (s00_axis_tready==0) begin
            @ (posedge axis_aclk) ;
        end
        @ (posedge axis_aclk) s00_axis_tdata = 16'hAAAA;s00_axis_tvalid = 1;s00_axis_tlast = 0;
        while (s00_axis_tready==0) begin
            @ (posedge axis_aclk) ;
        end
        @ (posedge axis_aclk) s00_axis_tdata = 16'h5555;s00_axis_tvalid = 1;s00_axis_tlast = 1;
        while (s00_axis_tready==0) begin
            @ (posedge axis_aclk) ;
        end
        @ (posedge axis_aclk) s00_axis_tdata = 16'h0000;s00_axis_tvalid = 0;
    end
endmodule
