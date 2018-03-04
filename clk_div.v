/*
DESCRIPTION
Clk Divider Wrapper

NOTES

Likely issues with widths over 32 bits for clk_div_basic.

Here are some resources:
https://learn.digilentinc.com/Documents/262
http://referencedesigner.com/tutorials/verilogexamples/verilog_ex_02.php
https://forums.xilinx.com/t5/General-Technical-Discussion/Best-practice-with-Clock-divider-in-FPGA/td-p/355829

TODO

*/

module clk_div #(
	parameter IN_FREQ = 50000000,
	parameter OUT_FREQ = 9600,
	parameter ARCH_SEL = 0
)(
	input clk,
	input rst,
	output new_clk
);

/**********
 * Internal Signals
**********/

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
clk_div_basic #(
	.IN_FREQ(IN_FREQ),
	.OUT_FREQ(OUT_FREQ)
)U_IP(
	.clk(clk),
	.rst(rst),
	.new_clk(new_clk)
);
/**********
 * Output Combinatorial Logic
 **********/
endmodule