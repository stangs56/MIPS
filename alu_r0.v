/*
DESCRIPTION

NOTES

TODO

*/

module alu_r0 #(
parameter DATA_WIDTH = 32,
parameter CTRL_WIDTH = 6,
parameter STATUS_WIDTH = 4,
parameter SHAMT_WIDTH = 5,
parameter DELAY = 0
)(
input clk,
input rst,
input [DATA_WIDTH*2-1:0] dataIn,
input [CTRL_WIDTH-1:0] ctrl,
input [SHAMT_WIDTH-1:0] shamt,
output [DATA_WIDTH-1:0] dataOut,
output [STATUS_WIDTH-1:0] status //CZSV
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

wire [DATA_WIDTH - 1:0] tmp_in [1:0]; //input as array
wire [DATA_WIDTH - 1:0] tmp_out;
wire [DATA_WIDTH - 1:0] tmp_calc [(2**CTRL_WIDTH)-1:0];
wire [DATA_WIDTH    :0] tmp_addout;
wire [DATA_WIDTH    :0] tmp_subout;
wire [2*DATA_WIDTH-1:0] tmp_multout;

wire [DATA_WIDTH - 1:0] tmp_neg;

reg  [DATA_WIDTH - 1:0] hi, lo;

/**********
 * Glue Logic
 **********/

  `UNPACK_ARRAY(DATA_WIDTH,2,tmp_in,dataIn, U_BLK_0, idx_0)

  //shift logical left
  assign tmp_calc[6'h0] = tmp_in[1] << shamt;

  //shift logical right
  assign tmp_calc[6'h2] = tmp_in[1] >> shamt;

  //shift arithmetic right
  assign tmp_calc[6'h3] = tmp_in[1] >>> shamt;

  //shift logical left
  assign tmp_calc[6'h4] = tmp_in[1] << tmp_in[0];

  //shift logical right
  assign tmp_calc[6'h5] = tmp_in[1] >> tmp_in[0];

  //shift arithmetic right
  assign tmp_calc[6'h7] = tmp_in[1] >>> tmp_in[0];

  //jump register
  assign tmp_calc[6'h8] = tmp_in[0];

  //from hi
  assign tmp_calc[6'h10] = hi;

  //from lo
  assign tmp_calc[6'h12] = lo;

  //add
  assign tmp_calc[6'h20] = tmp_addout[DATA_WIDTH-1:0];

  //addu
  assign tmp_calc[6'h21] = tmp_addout[DATA_WIDTH-1:0];

  //sub
  assign tmp_calc[6'h22] = tmp_subout[DATA_WIDTH-1:0];

  //subu
  assign tmp_calc[6'h23] = tmp_subout[DATA_WIDTH-1:0];

  //and
  assign tmp_calc[6'h24] = tmp_in[0] & tmp_in[1];

  //or
  assign tmp_calc[6'h25] = tmp_in[0] | tmp_in[1];

  //xor
  assign tmp_calc[6'h26] = tmp_in[0] ^ tmp_in[1];

  //nor
  assign tmp_calc[6'h27] = ~(tmp_in[0] | tmp_in[1]);

  //set on less than
  assign tmp_calc[6'h2A] = ($signed(tmp_in[0]) < $signed(tmp_in[1]));

  //set on less than unsigned
  assign tmp_calc[6'h2B] = (tmp_in[0] < tmp_in[1]);



/**********
 * Synchronous Logic
 **********/
 always @(posedge clk) begin
	if(rst) begin
		hi <= {DATA_WIDTH{1'b0}};
		lo <= {DATA_WIDTH{1'b0}};
	end else begin
		if(ctrl == 6'h11) begin //to hi
			hi <= tmp_in[0];
		end else if(ctrl == 6'h13) begin //to low
			lo <= tmp_in[0];
		end else if(ctrl == 6'h18 || ctrl == 6'h19) begin
			hi <= tmp_multout[2*DATA_WIDTH-1:DATA_WIDTH];
			lo <= tmp_multout[DATA_WIDTH-1:0];
		end
	end
 end

/**********
 * Glue Logic
 **********/

 assign tmp_out = tmp_calc[ctrl];

 assign tmp_neg = ~tmp_in[1] + 1'b1;

/**********
 * Components
 **********/

  	adder #(
		.BIT_WIDTH(DATA_WIDTH),
		.DELAY(0),
		.ARCH_SEL(0)
	)U_ADD(
		.clk(clk),
		.rst(rst),
		.inA(tmp_in[0]),
		.inB(tmp_in[1]),
		.out(tmp_addout)
	);

	adder #(
		.BIT_WIDTH(DATA_WIDTH),
		.DELAY(0),
		.ARCH_SEL(0)
	)U_SUB(
		.clk(clk),
		.rst(rst),
		.inA(tmp_in[0]),
		.inB(tmp_neg),
		.out(tmp_subout)
	);

	mult #(
		.BIT_WIDTH(DATA_WIDTH),
		.DELAY(0),
		.ARCH_SEL(0)
	)U_MULT(
		.clk(clk),
		.rst(rst),
		.inA(tmp_in[0]),
		.inB(tmp_in[1]),
		.out(tmp_multout)
	);

 	delay #(
		.BIT_WIDTH(DATA_WIDTH),
		.DEPTH(1),
		.DELAY(DELAY)
	)U_DELAY(
		.clk(clk),
		.rst(rst),
		.en_n(1'b0),
		.dataIn(tmp_out),
		.dataOut(dataOut)
	);

/**********
 * Output Combinatorial Logic
 **********/
 //status bits
 //CZSV
 //c flag
 assign status[3] = tmp_addout[DATA_WIDTH];

 //z flag
 assign status[2] = ~(|dataOut);

 //S flag
 assign status[1] = dataOut[DATA_WIDTH-1];

 //V flag
 assign status[0] =
	tmp_in[0][DATA_WIDTH-1]&&tmp_in[1][DATA_WIDTH-1]&&(!dataOut[DATA_WIDTH-1]) ||
	(!tmp_in[0][DATA_WIDTH-1])&&(!tmp_in[1][DATA_WIDTH-1])&&dataOut[DATA_WIDTH-1];

endmodule
