/*
DESCRIPTION

NOTES

TODO

*/

module sign_extend #(
	parameter BIT_WIDTH_IN = 16,
	parameter BIT_WIDTH_OUT = 32,
	parameter DEPTH = 2,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
	input clk,
	input rst,
	input is_signed,
	input [BIT_WIDTH_IN*DEPTH-1:0] dataIn,
	output [BIT_WIDTH_OUT*DEPTH-1:0] dataOut
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
 	sign_extend_r0 #(
		.BIT_WIDTH_IN(BIT_WIDTH_IN),
		.BIT_WIDTH_OUT(BIT_WIDTH_OUT),
		.DEPTH(DEPTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.is_signed(is_signed),
		.dataIn(dataIn),
		.dataOut(dataOut)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
