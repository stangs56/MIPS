/*
DESCRIPTION

NOTES

TODO

*/

module ALU_controller #(
	parameter FUNCT_WIDTH = 6,
	parameter ALUOP_WIDTH = 6,
	parameter ALUFUNCT_WIDTH = 6,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
	input  clk,
	input  rst,
	input  [FUNCT_WIDTH-1:0] funct,
	input  [ALUOP_WIDTH-1:0] ALUop,
	output [ALUFUNCT_WIDTH - 1:0] ALUfunct,
	output jr
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
 	ALU_controller_r0 #(
		.FUNCT_WIDTH(FUNCT_WIDTH),
		.ALUOP_WIDTH(ALUOP_WIDTH),
		.ALUFUNCT_WIDTH(ALUFUNCT_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.funct(funct),
		.ALUop(ALUop),
		.ALUfunct(ALUfunct),
		.jr(jr)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
