/*
DESCRIPTION
Testbench for clk divider.

NOTES

TODO
*/

module alu_r0_tb();

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
parameter DATA_WIDTH = 8;
parameter CTRL_WIDTH = 6;
parameter STATUS_WIDTH = 4;
parameter SHAMT_WIDTH = 5;
parameter DELAY = 0;
//UUT inputs
reg clk = 0;
reg rst = 1;
wire [DATA_WIDTH*2-1:0] dataIn;
reg [CTRL_WIDTH-1:0] ctrl;
reg [SHAMT_WIDTH-1:0] shamt;

//UUT outputs

wire [DATA_WIDTH-1:0] dataOut;
wire [STATUS_WIDTH-1:0] status;

integer i,j;
reg simState = 0;

reg [DATA_WIDTH - 1:0] dataIn_tmp [1:0];


/**********
 * Glue Logic 
 **********/
 
 `PACK_ARRAY(DATA_WIDTH, 2, dataIn_tmp, dataIn, U_BLK_0, idx_0)
 //`UNPACK_ARRAY(DATA_WIDTH, RD_DEPTH, q_tmpOut, q, U_BLK_1, idx_1)
 
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
  shamt = 0;
  ctrl = 0;
  `DELAY(10)
	
  //leaving reset 
  $display($time, "- Leaving Reset");
  rst = 0;
  `DELAY(10)
  
  //test logic
  //add
  ctrl = 6'h20;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < 2**DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		dataIn_tmp[1] = j;
		
		`DELAY(10)
		
		if(dataOut != i+j && (i+j) < 2**DATA_WIDTH) begin
			$display($time, "- Error Adding ", i, "+", j);
		end
	end
  end
  
  //sub
  ctrl = 6'h22;
  `DELAY(10)
  
  for(i = -1*2**(DATA_WIDTH-1); i < 2**(DATA_WIDTH-1); i = i+1) begin
	for(j = -1*2**(DATA_WIDTH-1); j < 2**(DATA_WIDTH-1); j = j+1) begin
		dataIn_tmp[0] = i;
		dataIn_tmp[1] = j;
		
		`DELAY(10)
		
		if($signed(dataOut) != i-j && 
				(i-j) > -1*2**(DATA_WIDTH-1) && 
				(i-j) < 2**(DATA_WIDTH-1)) begin
			$display($time, "- Error Subtracting ", i, "-", j);
		end
	end
  end
  
  //sll
  ctrl = 6'h00;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		shamt = j;
		
		`DELAY(10)
		
		if(dataOut != i << j && (i<<j) < 2**DATA_WIDTH) begin
			$display($time, "- Error sll ", i, "<<", j);
		end
	end
  end
  
   //srl
  ctrl = 6'h02;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		shamt = j;
		
		`DELAY(10)
		
		if(dataOut != i >> j && (i >> j) > 0) begin
			$display($time, "- Error srl ", i, ">>", j);
		end
	end
  end
  
  //sra
  ctrl = 6'h03;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		shamt = j;
		
		`DELAY(10)
		
		if(dataOut != i >>> j && (i >>> j) > 0) begin
			$display($time, "- Error sra ", i, ">>>", j);
		end
	end
  end
  
  //and
  ctrl = 6'h24;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < 2**DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		dataIn_tmp[1] = j;
		
		`DELAY(10)
	end
  end
  
  //or
  ctrl = 6'h25;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < 2**DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		dataIn_tmp[1] = j;
		
		`DELAY(10)
	end
  end
  
  //xor
  ctrl = 6'h26;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < 2**DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		dataIn_tmp[1] = j;
		
		`DELAY(10)
	end
  end
  
  //nor
  ctrl = 6'h27;
  `DELAY(10)
  
  for(i = 0; i < 2**DATA_WIDTH; i = i+1) begin
	for(j = 0; j < 2**DATA_WIDTH; j = j+1) begin
		dataIn_tmp[0] = i;
		dataIn_tmp[1] = j;
		
		`DELAY(10)
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
 alu_r0 #(
	.DATA_WIDTH(DATA_WIDTH),
	.CTRL_WIDTH(CTRL_WIDTH),
	.STATUS_WIDTH(STATUS_WIDTH),
	.SHAMT_WIDTH(SHAMT_WIDTH),
	.DELAY(DELAY)
)U_UUT(
	.clk(clk),
	.rst(rst),
	.dataIn(dataIn),
	.ctrl(ctrl),
	.shamt(shamt),
	.dataOut(dataOut),
	.status(status)
);

endmodule
