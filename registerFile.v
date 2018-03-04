/*
DESCRIPTION

NOTES

TODO

*/

module registerFile #(
parameter DATA_WIDTH = 32,
parameter RD_DEPTH = 2,
parameter REG_DEPTH = 32,
parameter ADDR_WIDTH = log2(REG_DEPTH),
parameter ARCH_SEL = 1
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
 
registerFile_r0 #(
  .DATA_WIDTH(DATA_WIDTH),
  .RD_DEPTH(RD_DEPTH),
  .REG_DEPTH(REG_DEPTH),
  .ADDR_WIDTH(ADDR_WIDTH)
)U_IP(
  .clk(clk),
  .rst(rst),
  .jal(jal),
  .wr(wr),
  .rr(rr),
  .rw(rw),
  .d(d),
  .q(q)
);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
