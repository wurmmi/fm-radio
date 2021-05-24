
`timescale 1 ns / 1 ps

    // Note that the master interface ignores the TREADY flow control
    // coming from the FIFO. We would have to implement another FIFO here to handle
    // this in a meaningful way. So, let's assume the AXI FIFO will always be ready to receive...
    
	module mySPIRxTx_v1_0 #
	(
		// Users to add parameters here
        parameter integer width	= 8,
        parameter integer clkdiv= 4,
        parameter integer sspol= 1,

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
        output wire sclk,
        output reg mosi = 0,
        input wire miso,
        output wire ss,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  axis_aclk,
		input wire  axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		output reg  m00_axis_tvalid = 0,
		output reg [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata = 0,
		output reg [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb = 8'hFF,
		output reg  m00_axis_tlast = 1,
		input wire  m00_axis_tready
	);

	// This holds the shift register
	reg [width-1 : 0] buffer = 0;
	reg buffer_full = 0;
	reg buffer_last = 0;

    // This is the miso shift register
	reg [width-1 : 0] rxbuffer = 0;
	reg rxbuffer_full = 0;
	reg rxbuffer_full_d = 0;

    // Counts the bits
	reg [5:0] bitcounter = 0;
	
	// Makes things slower
	reg [clkdiv-1:0] prescaler = 0;

    // State machine states
    localparam IDLE = 0;
    localparam S1 = 1;
    localparam S2 = 2;
    localparam S3 = 3;

    // Default state is IDLE
    reg [1:0] state = IDLE;
    reg state_last = 0;

    // Signals we are ready to receive
	assign s00_axis_tready = !buffer_full;
	
	// SPI Clock (data is valid during Low/High transition)
	assign sclk = state==S2 || state==S3;
	
	// SPI Slave Select
	assign ss = (state!=IDLE) ^ sspol;
	
	// This is the main state machine
    always @(posedge axis_aclk) begin
        // There is only one important rule for an AXI Stream interface:
        // If during the rising clock, S_AXIS_TVALID==1 and S_AXIS_TREADY==1, then we have to accept the data.  
        if (s00_axis_tvalid==1 && s00_axis_tready==1) begin
            buffer <= s00_axis_tdata[width-1 : 0];
            buffer_last <= s00_axis_tlast;
            buffer_full <= 1;
        end else if (state==S3 && prescaler==1) begin
            buffer_full <= 0;
        end
        
        rxbuffer_full_d <= rxbuffer_full;
        m00_axis_tvalid <= rxbuffer_full && !rxbuffer_full_d;
    
        prescaler <= prescaler+1;
        if (prescaler==0) begin // The state transitions are synchronized to the SPI bit clock
            case(state)
                IDLE:   begin // ss=0, sclk=0, mosi=0
                            mosi <= 0;
                            rxbuffer_full = 0;
                            if (buffer_full==1) begin
                                state_last <= buffer_last;
                                mosi <= buffer[width-1];
                                bitcounter <= 1;
                                state <= S1;
                            end
                        end
                S1:     begin // ss=1, sclk=0
                            rxbuffer_full = 0;
                            rxbuffer = (rxbuffer<<1) | miso;
                            if ( bitcounter==width ) begin
                                state <= S3;
                            end else begin
                                state <= S2;
                                buffer <= buffer<<1;
                            end
                        end
                S2:     begin // ss=1, sclk=1
                            state <= S1;
                            mosi <= buffer[width-1];
                            bitcounter <= bitcounter+1;
                            //rxbuffer = (rxbuffer<<1) | miso;
                        end
                S3:     begin // ss=1, sclk=1 (last bit)
                            //m00_axis_tdata[width-1 : 0] = (rxbuffer<<1) | miso;
                            m00_axis_tdata[width-1 : 0] = rxbuffer;
                            rxbuffer_full = 1;
                            if (buffer_full==1 && !state_last) begin
                                state_last <= buffer_last;
                                mosi <= buffer[width-1];
                                bitcounter <= 1;
                                state <= S1;
                            end else begin
                                state <= IDLE;
                            end
                        end
                default:begin
                            state <= IDLE;
                        end
            endcase
        end
    end

	endmodule
