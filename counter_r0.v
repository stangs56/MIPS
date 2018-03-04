/*
DESCRIPTION

NOTES

TODO

*/

module counter_r0 #(
	parameter MAX_COUNT = 32,
	parameter BIT_WIDTH = log2(MAX_COUNT),
	parameter DELAY = 0
)(
	input clk,
	input rst,
	input load,
	input run,
	input [BIT_WIDTH-1:0] dataIn,
	output [BIT_WIDTH-1:0] count
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

reg [BIT_WIDTH-1:0] tmp;

/**********
 * Glue Logic 
 **********/
/**********
 * Synchronous Logic
 **********/
 
 always @(posedge clk) begin
 
 if(rst) begin
	tmp <= {BIT_WIDTH{1'b0}};
 end else if(load) begin
	tmp <= dataIn;
 end else if(run) begin
	if(tmp == MAX_COUNT) begin
		tmp <= {BIT_WIDTH{1'b0}};
	end else begin
		tmp <= tmp + 1;
	end
 end else begin
	tmp <= tmp;
 end
 
 end
/**********
 * Glue Logic 
 **********/
/**********
 * Components
 **********/
 
  	delay #(
		.BIT_WIDTH(BIT_WIDTH),
		.DEPTH(1),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.en_n(1'b0),
		.dataIn(tmp),
		.dataOut(count)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
 
endmodule
