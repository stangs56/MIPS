/*
DESCRIPTION

NOTES

TODO

*/

module ALU_controller_r0 #(
	parameter FUNCT_WIDTH = 6,
	parameter ALUOP_WIDTH = 6,
	parameter ALUFUNCT_WIDTH = 6,
	parameter DELAY = 0
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

reg [ALUFUNCT_WIDTH - 1:0] tmp;

/**********
 * Glue Logic 
 **********/
 
 always @(funct, ALUop) begin

	if(ALUop == {ALUOP_WIDTH{1'b0}}) begin
		tmp <= funct;
	end else begin
		tmp <= ALUop;
	end

end
 
/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
/**********
 * Output Combinatorial Logic
 **********/
 
 assign ALUfunct = tmp;
 assign jr = (ALUop == 6'h08);
 
endmodule
