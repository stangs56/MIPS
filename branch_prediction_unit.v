/*
DESCRIPTION

NOTES

TODO

*/

module branch_prediction_unit #(
	parameter BIT_WIDTH = 32,
	parameter REG_ADDR_WIDTH = 5,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
  input clk,
	input rst,

	input [REG_ADDR_WIDTH-1:0] rs,
	input [REG_ADDR_WIDTH-1:0] rt,

	input ex_memRead,
	input [REG_ADDR_WIDTH-1:0] ex_rt,

	output PC_write,
  output IDIF_write,
  output ex_noop
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
 	branch_prediction_unit_r0 #(
		.BIT_WIDTH(BIT_WIDTH),
		.REG_ADDR_WIDTH(REG_ADDR_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.rs(rs),
		.rt(rt),

		.ex_memRead(ex_memRead),
		.ex_rt(ex_rt),

		.PC_write(PC_write),
		.IDIF_write(IDIF_write),
		.ex_noop(ex_noop)
	);

/**********
 * Output Combinatorial Logic
 **********/
endmodule
