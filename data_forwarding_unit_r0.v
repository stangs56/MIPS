/*
DESCRIPTION

NOTES

TODO

*/

module data_forwarding_unit_r0 #(
	parameter BIT_WIDTH = 32,
	parameter REG_ADDR_WIDTH = 5;
	parameter DELAY = 0
)(
	input clk,
	input rst,

	input [REG_ADDR_WIDTH-1:0] rs,
	input [REG_ADDR_WIDTH-1:0] rt,

	input mem_writeReg,
	input [REG_ADDR_WIDTH-1:0] mem_regToWrite,

	input wb_writeReg,
	input [REG_ADDR_WIDTH-1:0] wb_regToWrite,

	output reg [1:0] forwardA,
	output reg [1:0] forwardB
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
	forwardA <= 2'b0;
	forwardB <= 2'b0;

	//rs forwarding
	if(rs != {REG_ADDR_WIDTH{1'b0}}) begin
		if(rs == mem_regToWrite && mem_writeReg) begin
			forwardA <= 2'b1;
		end else if(rs == wb_regToWrite && wb_writeReg) begin
			forwardA <= 2'b10;
		end
	end


	//rt forwarding
	if(rt != {REG_ADDR_WIDTH{1'b0}}) begin
		if(rt == mem_regToWrite && mem_writeReg) begin
			forwardB <= 2'b1;
		end else if(rt == wb_regToWrite && wb_writeReg) begin
			forwardB <= 2'b10;
		end
	end
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
