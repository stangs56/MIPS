/*
DESCRIPTION

NOTES

TODO

*/

module adder_r0 #(
	parameter BIT_WIDTH = 31,
	parameter DELAY = 0
)(
	input clk,
	input rst,
	input [BIT_WIDTH-1:0] inA,
	input [BIT_WIDTH-1:0] inB,
	output [BIT_WIDTH:0] out
);

/**********
 * Internal Signals
**********/

wire [BIT_WIDTH:0] tmp;

/**********
 * Glue Logic 
 **********/
 
 assign tmp = inA + inB;
 
/**********
 * Synchronous Logic
 **********/
 

/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
 
  	delay #(
		.BIT_WIDTH(BIT_WIDTH+1),
		.DEPTH(1),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.en_n(1'b0),
		.dataIn(tmp),
		.dataOut(out)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
 
endmodule
