/*
DESCRIPTION

NOTES

TODO

*/

module datapath #(
	parameter BIT_WIDTH = 32,
	parameter ADDR_WIDTH = 32,	
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
	input  clk,
	input  rst,
	input  rst_clk
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
 	datapath_r0 #(
		.BIT_WIDTH(BIT_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.rst_clk(rst_clk)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
