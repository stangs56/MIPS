/*
DESCRIPTION

NOTES

TODO

*/

module dataRAM_r0 #(
	parameter BIT_WIDTH = 32,
	parameter DELAY = 0
)(
	input  clk,
	input  [BIT_WIDTH-1:0] data,
	input  [5:0] addr,
	input  wren,
	input  isSigned,
	input  [1:0] dataSize,
	
	output reg [BIT_WIDTH-1:0] q
);

/**********
 * Internal Signals
**********/
wire [7:0] q0, q1, q2, q3;
wire wren0, wren1, wren2, wren3;

wire [BIT_WIDTH-1:0] out_word;
wire [BIT_WIDTH-1:0] out_half1, out_half0;

reg  [7:0] out_byte;
reg  [15:0] out_half;

/**********
 * Glue Logic 
 **********/
 
 
 
 
 assign wren3 = dataSize[1] || 
					(dataSize == 2'b01) && addr[1] || 
					addr[1:0] == 2'b11;
 
 assign wren2 = dataSize[1] || 
					(dataSize == 2'b01) && addr[1] || 
					addr[1:0] == 2'b10;
					
 assign wren1 = dataSize[1] || 
					(dataSize == 2'b01) && !addr[1] || 
					addr[1:0] == 2'b01;

 assign wren0 = dataSize[1] || 
					(dataSize == 2'b01) && !addr[1] || 
					addr[1:0] == 2'b00;
 
/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
 ram_r0 U_MEM_0 (
	.clock(clk),
	.data(data[7:0]),
	.addr(addr),
	.wren( wren0 ),
	.q(q0)
	);
 
 ram_r0 U_MEM_1 (
	.clock(clk),
	.data(data[15:8]),
	.addr(addr),
	.wren( wren1 ),
	.q(q1)
	);
	
 ram_r0 U_MEM_2 (
	.clock(clk),
	.data(data[23:16]),
	.addr(addr),
	.wren( wren2 ),
	.q(q2)
	);
	
 ram_r0 U_MEM_3 (
	.clock(clk),
	.data(data[31:24]),
	.addr(addr),
	.wren( wren3 ),
	.q(q3)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
 assign out_word = {q3, q2, q1, q0};
 assign out_half1 = {q3, q2};
 assign out_half0 = {q1, q0};
 
 //output selection
 always @* begin
	case(addr[1:0])
		2'b00 : out_byte <= q0;
		2'b01 : out_byte <= q1;
		2'b10 : out_byte <= q2;
		2'b11 : out_byte <= q3;
	endcase
	
	if(addr[1]) begin
		out_half <= out_half1;
	end else begin
		out_half <= out_half0;
	end
 end
 
 //extension and final selection
 always @* begin
	if(isSigned) begin
		case(dataSize)
			2'b10, 2'b11 : q <= out_word;
			2'b01 : q <= {{16{out_half[15]}}, out_half};
			2'b00 : q <= {{24{out_byte[7]}}, out_byte};
		endcase
	end else begin
		case(dataSize)
			2'b10, 2'b11 : q <= out_word;
			2'b01 : q <= {16'b0, out_half};
			2'b00 : q <= {24'b0, out_byte};
		endcase
	end
 end
 
endmodule
