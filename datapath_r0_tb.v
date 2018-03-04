/*
DESCRIPTION
Testbench for clk divider.

NOTES

TODO
*/

module datapath_r0_tb();

/*
Defines
*/
`define DELAY(TIME_CLK) #(10*TIME_CLK); //delays one clk cycle, TIME_CLK = number of clk cycles to delay

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

//UUT parameters
parameter ADDR_WIDTH = 32;
parameter BIT_WIDTH = 32;
parameter DELAY     = 0;
//UUT inputs
reg clk  = 0;
reg rst  = 1;
reg rst_clk = 1;

//UUT outputs


reg simState = 0;



/**********
 * Glue Logic 
 **********/
 
/**********
 * Synchronous Logic
 **********/
always begin 
	if (simState != 1) begin
		`DELAY(1/2)
		clk = ~clk;
	end
end

initial begin
  //SIM
  simState = 0;
  
	
  //Start Sim, initialize all inputs
  $display($time, "- Starting Sim");
  clk = 0;
  rst = 1;
  rst_clk = 1;
  `DELAY(10)
  
  rst_clk = 0;
  `DELAY(10)
	
  //leaving reset 
  $display($time, "- Leaving Reset");
  rst = 0;
  `DELAY(1000)
  
  
	
	//End Simulation
	$display($time, "- End Simulation");
	simState = 1;
end
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
 	datapath_r0 #(
		.BIT_WIDTH(BIT_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.rst_clk(rst_clk)
	);

endmodule
