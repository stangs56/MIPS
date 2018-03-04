/*
DESCRIPTION

NOTES

TODO

*/

module sign_extend_r0 #(
	parameter BIT_WIDTH_IN = 16,
	parameter BIT_WIDTH_OUT = 32,
	parameter DEPTH = 1,
	parameter DELAY = 0
)(
	input clk,
	input rst,
	input is_signed,
	input [BIT_WIDTH_IN*DEPTH-1:0] dataIn,
	output [BIT_WIDTH_OUT*DEPTH-1:0] dataOut
);


/**********
	 *  Array Packing Defines 
	 **********/
//These are preprocessor defines similar to C/C++ preprocessor or VHDL functions
	`define PACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_SRC,PK_DEST, BLOCK_ID, GEN_VAR)    genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[((PK_WIDTH)*GEN_VAR+((PK_WIDTH)-1)):((PK_WIDTH)*GEN_VAR)] = PK_SRC[GEN_VAR][((PK_WIDTH)-1):0]; end endgenerate
	`define UNPACK_ARRAY(PK_WIDTH,PK_DEPTH,PK_DEST,PK_SRC, BLOCK_ID, GEN_VAR)  genvar GEN_VAR; generate for (GEN_VAR=0; GEN_VAR<(PK_DEPTH); GEN_VAR=GEN_VAR+1) begin: BLOCK_ID assign PK_DEST[GEN_VAR][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*GEN_VAR+(PK_WIDTH-1)):((PK_WIDTH)*GEN_VAR)]; end endgenerate

/**********
 * Internal Signals
**********/

	wire [BIT_WIDTH_IN - 1:0] tmp [DEPTH - 1:0]; //input as array
	reg [BIT_WIDTH_OUT - 1:0] tmpOut [DEPTH - 1:0]; //input as array
	
	wire[BIT_WIDTH_OUT*DEPTH-1:0] tmpDelay;
	
	
	integer i;

/**********
 * Glue Logic 
 **********/
 
 `UNPACK_ARRAY(BIT_WIDTH_IN,DEPTH,tmp,dataIn, U_BLK_0, idx_0)
 
/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic 
 **********/
 
 `PACK_ARRAY(BIT_WIDTH_OUT,DEPTH,tmpOut,tmpDelay,U_BLK_1,idx_1)
 
/**********
 * Components
 **********/
 
  	delay #(
		.BIT_WIDTH(BIT_WIDTH_OUT),
		.DEPTH(DEPTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.en_n(1'b0),
		.dataIn(tmpDelay),
		.dataOut(dataOut)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
 always @(tmp, is_signed) begin
 
	for(i = 0; i < DEPTH; i = i + 1) begin
		if(is_signed) begin
			tmpOut[i][BIT_WIDTH_OUT-1:BIT_WIDTH_IN] <= 
				{(BIT_WIDTH_OUT-BIT_WIDTH_IN){tmp[i][BIT_WIDTH_IN-1]}};
		end else begin
			tmpOut[i][BIT_WIDTH_OUT-1:BIT_WIDTH_IN] <= 
				{(BIT_WIDTH_OUT-BIT_WIDTH_IN){1'b0}};
		end
		
		tmpOut[i][BIT_WIDTH_IN-1:0] <= tmp[i][BIT_WIDTH_IN-1:0];
	end
 
 end
 
 
endmodule
