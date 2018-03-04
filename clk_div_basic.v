/*
DESCRIPTION
Basic Clk Divider

NOTES
Uses a counter to divide a clock input signal.
Clk dividing is a big topic in the field since we have to add logic to a clock line
which is obvious not good for set up and hold timing constraints.

Likely issues with widths over 32 bits.

Here are some resources:
https://learn.digilentinc.com/Documents/262
http://referencedesigner.com/tutorials/verilogexamples/verilog_ex_02.php
https://forums.xilinx.com/t5/General-Technical-Discussion/Best-practice-with-Clock-divider-in-FPGA/td-p/355829

TODO

*/

module clk_div_basic #(
	parameter IN_FREQ = 50000000,
	parameter OUT_FREQ = 9600
)(
	input clk,
	input rst,
	output reg new_clk //instead of intermediate reg signals for outputs, can do this to force output to reg, but lose output comb logic
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

localparam CNT_WIDTH = log2(IN_FREQ/OUT_FREQ);
localparam CNT_MAX = (IN_FREQ/OUT_FREQ)/2;

wire [CNT_WIDTH-1:0] cntmax;
reg [CNT_WIDTH-1:0] cnt;

/**********
 * Glue Logic 
 **********/
assign cntmax = CNT_MAX-1; 
/**********
 * Synchronous Logic
 **********/
always @(posedge clk or posedge rst) begin
	if(rst) begin
		cnt <= {(CNT_WIDTH){1'b0}};
		new_clk <= 1'b0;
	end else begin
		if(cnt^cntmax) begin//xor to prevent casting up to 32 bit for comparison, same as !=
			new_clk <= new_clk;//when we arent at the new value, hold the value
			cnt <= cnt+1;//note this throws a warning since it is truncating the 1 to fit the cnt width
		end
		else begin
			cnt <= {(CNT_WIDTH){1'b0}};
			new_clk <= ~new_clk;
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
endmodule