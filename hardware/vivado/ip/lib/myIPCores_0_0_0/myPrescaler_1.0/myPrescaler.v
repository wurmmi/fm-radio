`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.12.2017 01:05:32
// Design Name: 
// Module Name: myPrescaler
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


module myPrescaler #
	(
		parameter integer CounterWidth	= 8,
		parameter integer ResetValue	= 128
	)
	(
    input clk,
    output reg prescale = 0
    );
    
	reg [CounterWidth-1:0] counter = 0;

    always @(posedge clk) begin
        if (counter==ResetValue) begin
            counter <= 0;
            prescale <= !prescale;
        end else begin
            counter <= counter+1;
        end
    end    
    
endmodule
