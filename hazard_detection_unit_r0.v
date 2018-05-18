/*
DESCRIPTION

NOTES

TODO

*/

module hazard_detection_unit_r0 #(
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
reg IDIF_write_tmp;
/**********
 * Glue Logic
 **********/
/**********
 * Synchronous Logic
 **********/
always @* begin
	ex_noop <= 1'b0;
	PC_write <= 1'b1;
	IDIF_write_tmp <= 1'b1;

	//load use hazard
	if(ex_memRead && (ex_rt == rs || ex_rt == rt)) begin
		ex_noop <= 1'b1;
		PC_write <= 1'b0;
		IDIF_write_tmp <= 1'b0;
	end
end

always @(posedge clk) begin
	IDIF_write <= IDIF_write_tmp;

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
