/*
DESCRIPTION

NOTES

TODO

*/

module counter #(
	parameter MAX_COUNT = 32,
	parameter BIT_WIDTH = log2(MAX_COUNT),
	parameter DELAY = 0,
	parameter ARCH_SEL = 0
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
 	counter_r0 #(
		.MAX_COUNT(MAX_COUNT),
		.BIT_WIDTH(BIT_WIDTH),
		.DELAY(DELAY)
	)U_IP(
		.clk(clk),
		.rst(rst),
		.load(load),
		.run(run),
		.dataIn(dataIn),
		.count(count)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
