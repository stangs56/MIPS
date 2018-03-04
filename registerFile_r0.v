/*
DESCRIPTION

NOTES

TODO

*/

module registerFile_r0 #(
parameter DATA_WIDTH = 32,
parameter RD_DEPTH = 2,
parameter REG_DEPTH = 32,
parameter ADDR_WIDTH = log2(REG_DEPTH)
)(
input clk,
input rst,
input jal,
input wr,
input [ADDR_WIDTH*RD_DEPTH-1:0] rr,
input [ADDR_WIDTH-1:0] rw,
input [DATA_WIDTH-1:0] d,
output [DATA_WIDTH*RD_DEPTH-1:0] q
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

function integer log2; //This is a macro function (no hardware created) which finds the log2, returns log2
   input [31:0] val; //input to the function
   integer 	i;
   begin
      log2 = 0;
      for(i = 0; 2**i < val; i = i + 1)
		log2 = i + 1;
   end
endfunction

wire [ADDR_WIDTH - 1:0] rr_tmp [RD_DEPTH - 1:0]; //input as array
wire [DATA_WIDTH - 1:0] q_tmpOut [RD_DEPTH - 1:0]; 

reg  [DATA_WIDTH - 1:0] data [REG_DEPTH - 1:0];

integer i; //iterators

/**********
 * Glue Logic 
 **********/
 
 `UNPACK_ARRAY(ADDR_WIDTH, RD_DEPTH, rr_tmp, rr, U_BLK_0, idx_0)
 `PACK_ARRAY(DATA_WIDTH, RD_DEPTH, q_tmpOut, q, U_BLK_1, idx_1)
 
/**********
 * Synchronous Logic
 **********/
 
 always @(posedge clk) begin
  
  if(rst == 1'b1)	begin
    for(i=0; i < REG_DEPTH; i=i+1) begin
      data[i] = {(DATA_WIDTH){1'b0}};
    end
  end else begin
	 if(wr && jal) begin //jump and link
		data[31] = d;
    end else if(wr && rw != 0) begin //regular write
	   data[rw] = d;
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
 
 genvar idx_out;
 generate
  for(idx_out = 0; idx_out < RD_DEPTH; idx_out=idx_out+1)
  begin: U_BLK_out
    assign q_tmpOut[idx_out] = data[rr_tmp[idx_out]];
  end
 
 endgenerate
 
endmodule
