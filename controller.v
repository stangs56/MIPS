/*
DESCRIPTION

NOTES

TODO

*/

module controller #(
	parameter OP_WIDTH = 6,
	parameter ALUOP_WIDTH = 6,
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
)(
	input  clk,
	input  rst,
	input  [OP_WIDTH-1:0] opcode,
	
	output [ALUOP_WIDTH-1:0] ALUop,
	
	output regWrite,
	output regDest,
	output memToReg,
	
	output load_upper,
	output isSigned,
	output ALUsrc,
	
	output jump,
	output jal,
	output branch,
	output eq,
	
	output memRead,
	output memWrite,
	
	output memIsSigned,
	output [1:0] memDataSize,
	
	output [ALUOP_WIDTH+9-1:0] combined
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
 	controller_r0 #(
		.OP_WIDTH(OP_WIDTH),
		.ALUOP_WIDTH(ALUOP_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.opcode(opcode),
		.ALUop(ALUop),
		.regWrite(regWrite),
	   .regDest(regDest),
	   .memToReg(memToReg),
		
		.load_upper(load_upper),
	   .isSigned(isSigned),
		.ALUsrc(ALUsrc),
	
		.jump(jump),
		.jal(jal),
		.branch(branch),
		.eq(eq),
	
		.memRead(memRead),
		.memWrite(memWrite),
		
		.memIsSigned(memIsSigned),
		.memDataSize(memDataSize),
		
		.combined(combined)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
