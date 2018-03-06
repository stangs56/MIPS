/*
DESCRIPTION

NOTES

TODO

*/

module dataRAM #(
	parameter BIT_WIDTH = 32,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
	input  clk,
	input  [BIT_WIDTH-1:0] data,
	input  [7:0] addr,
	input  wren,
	input  isSigned,
	input  [1:0] dataSize,
	
	output [BIT_WIDTH-1:0] q
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
 	dataRAM_r0 #(
		.BIT_WIDTH(BIT_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.data(data),
		.addr(addr), 
		.wren(wren),
		.isSigned(isSigned),
		.dataSize(dataSize),
		.q(q)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
