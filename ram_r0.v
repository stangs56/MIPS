/*
DESCRIPTION

NOTES

TODO

*/

module ram_r0 #(
	parameter BIT_WIDTH = 8,
	parameter DELAY = 0
)(
	input  clock,
	input  [BIT_WIDTH-1:0] data,
	input  [5:0] addr,
	input  wren,

	output reg [BIT_WIDTH-1:0] q
);

/**********
 * Internal Signals
**********/
 reg [BIT_WIDTH-1:0] dataReg [63:0];

/**********
 * Glue Logic
 **********/

/**********
 * Synchronous Logic
 **********/
 always @(posedge clock) begin
	if(wren) begin
		dataReg[addr] <= data;
	end
	q <= dataReg[addr];
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

 //output selection


endmodule
