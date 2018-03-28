/*
DESCRIPTION

NOTES

TODO

*/

module branch_prediction_unit #(
	parameter ADDR_WIDTH = 6,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
  input clk,
	input rst,

  input [ADDR_WIDTH-1:0] predictAddr,

  input [ADDR_WIDTH-1:0] updateAddr,
  input branchTaken,
  input update;

  output prediction );

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
 	branch_prediction_unit_r0 #(
		.ADDR_WIDTH(ADDR_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.predictAddr(predictAddr),
		.updateAddr(updateAddr),
		.branchTaken(branchTaken),
    .update(update),
		.prediction(prediction)
	);

/**********
 * Output Combinatorial Logic
 **********/
endmodule
