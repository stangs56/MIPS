/*
DESCRIPTION

NOTES

TODO

*/

module alu #(
parameter DATA_WIDTH = 32,
parameter CTRL_WIDTH = 6,
parameter STATUS_WIDTH = 4,
parameter SHAMT_WIDTH = 5,
parameter DELAY = 0,
parameter ARCH_SEL = 0
)(
input clk,
input rst,
input [DATA_WIDTH*2-1:0] dataIn,
input [CTRL_WIDTH-1:0] ctrl,
input [SHAMT_WIDTH-1:0] shamt,
output [DATA_WIDTH-1:0] dataOut,
output [STATUS_WIDTH-1:0] status
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
 alu_r0 #(
.DATA_WIDTH(DATA_WIDTH),
.CTRL_WIDTH(CTRL_WIDTH),
.STATUS_WIDTH(STATUS_WIDTH),
.SHAMT_WIDTH(SHAMT_WIDTH),
.DELAY(DELAY)
)U_ALU_R0(
.clk(clk),
.rst(rst),
.dataIn(dataIn),
.ctrl(ctrl),
.shamt(shamt),
.dataOut(dataOut),
.status(status)
);
/**********
 * Output Combinatorial Logic
 **********/
endmodule