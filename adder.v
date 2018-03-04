/*
DESCRIPTION

NOTES

TODO

*/

module adder #(
	parameter BIT_WIDTH = 32,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
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

/**********
 * Glue Logic 
 **********/
/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
 	adder_r0 #(
		.BIT_WIDTH(BIT_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.inA(inA),
		.inB(inB),
		.out(out)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
