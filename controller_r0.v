/*
DESCRIPTION

NOTES

TODO

*/

module controller_r0 #(
	parameter OP_WIDTH = 6,
	parameter ALUOP_WIDTH = 6,
	parameter DELAY = 0
)(
	input  clk,
	input  rst,
	input  [OP_WIDTH-1:0] opcode,
	
	output reg [ALUOP_WIDTH-1:0] ALUop,
	
	output reg regWrite,
	output reg regDest,
	output reg memToReg,
	
	output reg load_upper,
	output reg isSigned,
	output reg ALUsrc,
	
	output reg jump,
	output reg jal,
	output reg branch,
	output reg eq,
	
	output reg memRead,
	output reg memWrite,
	
	output reg memIsSigned,
	output reg [1:0] memDataSize,
	
	output [ALUOP_WIDTH+9-1:0] combined
);

/**********
 * Internal Signals
**********/

/**********
 * Glue Logic 
 **********/
 always @(opcode) begin
 
 ALUop       <= {ALUOP_WIDTH{1'b0}};
 
 regWrite    <= 1'b0;
 regDest     <= 1'b0;
 memToReg    <= 1'b0;
 
 load_upper  <= 1'b0;
 isSigned    <= 1'b0;
 ALUsrc      <= 1'b0;
 
 jump        <= 1'b0;
 jal         <= 1'b0;
 branch      <= 1'b0;
 eq          <= 1'b0;
 
 memRead     <= 1'b0;
 memWrite    <= 1'b0;
 memIsSigned <= 1'b0;
 memDataSize <= 2'b0;
 
 
 case(opcode)
	//0x00 - r-type
	{OP_WIDTH{1'b0}} : begin
		regWrite <= 1'b1;
		regDest  <= 1'b1;
	end
	
	//immediate arith and lui
	6'h08, 6'h09, 6'h0A, 6'h0B, 6'h0C, 6'h0D, 6'h0E, 6'h0F : begin
		regWrite <= 1'b1;
		ALUsrc   <= 1'b1;
		
		//lookup table for ALUop mappings
		//maps opcode to function codes
		case(opcode)
			6'h08 : ALUop <= 6'h20;
			6'h09 : ALUop <= 6'h21;
			6'h0A : ALUop <= 6'h2A;
			6'h0B : ALUop <= 6'h2B;
			6'h0C : ALUop <= 6'h24;
			6'h0D : ALUop <= 6'h25;
			6'h0E : ALUop <= 6'h26;
			6'h0F : begin //lui
				ALUop      <= 6'h20; 
				load_upper <= 1'b1;
			end
		endcase
		
	end
	
	//beq
	6'h04 : begin
		branch   <= 1'b1;
		ALUop    <= 6'h22; //subtract
		eq       <= 1'b1;
		isSigned <= 1'b1;
	end
	
	//bne
	6'h05 : begin
		branch <= 1'b1;
		ALUop  <= 6'h22; //subtract
		isSigned <= 1'b1;
	end
	
	//jump
	6'h02 : begin
		jump   <= 1'b1;
	end
	
	//jal
	6'h03 : begin
		jump     <= 1'b1;
		jal      <= 1'b1;
		regWrite <= 1'b1;
	end
	
	//load mem
	6'h23, 6'h24, 6'h25 : begin
		ALUop    <= 6'h20; //add
		memRead  <= 1'b1;
		memToReg <= 1'b1;
		regWrite <= 1'b1;
		isSigned <= 1'b1;
		case(opcode)
			6'h23 : begin //lw
				memIsSigned <= 1'b1;
				memDataSize <= 2'b10;
			end
			6'h24 : begin //lbu
				memIsSigned <= 1'b0;
				memDataSize <= 2'b00;
			end
			6'h25 : begin //lhu
				memIsSigned <= 1'b0;
				memDataSize <= 2'b01;
			end
		endcase
	end
	
	//store mem
	6'h28, 6'h29, 6'h2B : begin
		ALUop    <= 6'h20; //add
		memWrite <= 1'b1;
		isSigned <= 1'b1;
		case(opcode)
			6'h28 : begin //sb
				memIsSigned <= 1'b0;
				memDataSize <= 2'b00;
			end
			6'h29 : begin //sh
				memIsSigned <= 1'b0;
				memDataSize <= 2'b01;
			end
			6'h2B : begin //sw
				memIsSigned <= 1'b0;
				memDataSize <= 2'b10;
			end
		endcase
	end
 
 endcase
 
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
 
 //provides an easy way to register all of the control signals at once
 assign combined = {ALUop, regWrite, regDest, memToReg, 
				isSigned, ALUsrc, jump, branch, memRead, memWrite};
 
endmodule
