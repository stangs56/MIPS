/*
DESCRIPTION

NOTES

TODO

*/

module data_forwarding_unit #(
	parameter BIT_WIDTH = 32,
	parameter REG_ADDR_WIDTH = 5,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
	input clk,
	input rst,

	input rs,
	input rt,

	input mem_writeReg,
	input [REG_ADDR_WIDTH-1:0] mem_regToWrite,

	input wb_writeReg,
	input [REG_ADDR_WIDTH-1:0] wb_regToWrite,

	output [1:0] forwardA,
	output [1:0] forwardB
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
 	data_forwarding_unit_r0 #(
		.BIT_WIDTH(BIT_WIDTH),
		.REG_ADDR_WIDTH(REG_ADDR_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.rs(rs),
		.rt(rt),

		.mem_writeReg(mem_writeReg),
		.mem_regToWrite(mem_regToWrite),

		.wb_writeReg(wb_writeReg),
		.wb_regToWrite(wb_regToWrite),

		.forwardA(forwardA),
		.forwardB(forwardB)
	);

/**********
 * Output Combinatorial Logic
 **********/
endmodule
