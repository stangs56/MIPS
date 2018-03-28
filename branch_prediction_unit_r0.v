/*
DESCRIPTION

NOTES

TODO

*/

module branch_prediction_unit_r0 #(
	parameter BIT_WIDTH = 32,
	parameter REG_ADDR_WIDTH = 5,
	parameter DELAY = 0
)(
	input clk,
	input rst,

	input [REG_ADDR_WIDTH-1:0] rs,
	input [REG_ADDR_WIDTH-1:0] rt,

	input ex_memRead,
	input [REG_ADDR_WIDTH-1:0] ex_rt,

	output reg PC_write,
  output reg IDIF_write,
  output reg ex_noop
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
always @* begin

end

/**********
 * Glue Logic
 **********/
/**********
 * Components
 **********/
/**********
 * Output Combinatorial Logic
 **********/

endmodule
