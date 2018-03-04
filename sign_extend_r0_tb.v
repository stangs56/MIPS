/*
DESCRIPTION
Testbench for clk divider.

NOTES

TODO
*/

module sign_extend_r0_tb();

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
parameter BIT_WIDTH_IN  = 16;
parameter BIT_WIDTH_OUT = 32;
parameter DEPTH         = 1;
parameter DELAY         = 0;
//UUT inputs
reg clk = 0;
reg rst = 1;
reg is_signed = 0;
wire [BIT_WIDTH_IN*DEPTH-1:0] dataIn;

//UUT outputs

wire [BIT_WIDTH_OUT*DEPTH-1:0] dataOut;

integer i,j;
reg simState = 0;

reg [BIT_WIDTH_IN - 1:0] dataIn_tmp [DEPTH:0];

wire [BIT_WIDTH_OUT - 1:0] dataOut_tmp [DEPTH:0];


/**********
 * Glue Logic 
 **********/
 
 `PACK_ARRAY(BIT_WIDTH_IN, DEPTH, dataIn_tmp, dataIn, U_BLK_0, idx_0)
 `UNPACK_ARRAY(BIT_WIDTH_OUT, DEPTH, dataOut_tmp, dataOut, U_BLK_1, idx_1)
 
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
  `DELAY(10)
	
  //leaving reset 
  $display($time, "- Leaving Reset");
  rst = 0;
  is_signed = 0;
  `DELAY(10)
  
  //test logic
  //unsigned test
  for(i = 0; i < 2**BIT_WIDTH_IN; i = i+1) begin
    dataIn_tmp[0] = i;
	 
	 `DELAY(10)
	 
	 if(dataOut_tmp[0] != i) begin
	   $display($time, "- Error extending unsigned: ", i);
	 end
  end
  
  //signed test
  is_signed = 1;
  `DELAY(10)
  
  for(i = -1*2**(BIT_WIDTH_IN-1); i < 2**(BIT_WIDTH_IN-1); i = i+1) begin
    dataIn_tmp[0] = i;
	 
	 `DELAY(10)
	 
	 if(dataOut_tmp[0] != i) begin
	   $display($time, "- Error extending unsigned: ", i);
	 end
  end
	
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
 	sign_extend_r0 #(
		.BIT_WIDTH_IN(BIT_WIDTH_IN),
		.BIT_WIDTH_OUT(BIT_WIDTH_OUT),
		.DEPTH(DEPTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.is_signed(is_signed),
		.dataIn(dataIn),
		.dataOut(dataOut)
	);

endmodule
