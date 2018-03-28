/*
DESCRIPTION

NOTES

TODO

*/

module branch_prediction_unit_r0 #(
	parameter ADDR_WIDTH = 6,
	parameter DELAY = 0
)(
	input clk,
	input rst,

	input [ADDR_WIDTH-1:0] predictAddr,

  input [ADDR_WIDTH-1:0] updateAddr,
  input branchTaken,
  input update,

  output prediction  );

/**********
 * Internal Signals
**********/

reg [1:0] predictionHistory [2**ADDR_WIDTH-1:0];
integer i;

/**********
 * Glue Logic
 **********/
/**********
 * Synchronous Logic
 **********/

 //update prediction history
always @(posedge clk) begin

  if(rst) begin
    for(i = 0; i < 2**ADDR_WIDTH; i = i+1) begin
      predictionHistory[i] <= 2'b01;
    end
  end else if(update) begin
    case(predictionHistory[updateAddr])
      2'b00 : begin
        if(branchTaken) begin
          predictionHistory[updateAddr] <= 2'b01;
        end else begin
          predictionHistory[updateAddr] <= 2'b00;
        end
      end

      2'b01 : begin
        if(branchTaken) begin
          predictionHistory[updateAddr] <= 2'b10;
        end else begin
          predictionHistory[updateAddr] <= 2'b00;
        end
      end

      2'b10 : begin
        if(branchTaken) begin
          predictionHistory[updateAddr] <= 2'b11;
        end else begin
          predictionHistory[updateAddr] <= 2'b01;
        end
      end

      2'b11 : begin
        if(branchTaken) begin
          predictionHistory[updateAddr] <= 2'b11;
        end else begin
          predictionHistory[updateAddr] <= 2'b10;
        end
      end
    endcase
  end
end

//prediction
assign prediction = predictionHistory[predictAddr][1];

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
