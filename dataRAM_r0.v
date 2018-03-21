/*
DESCRIPTION

NOTES

TODO

*/

module dataRAM_r0 #(
	parameter BIT_WIDTH = 32,
	parameter DELAY = 0
)(
	input  clk,
	input  [BIT_WIDTH-1:0] data,
	input  [7:0] addr,
	input  wren,
	input  isSigned,
	input  [1:0] dataSize,

	output reg [BIT_WIDTH-1:0] q
);

/**********
 * Internal Signals
**********/
reg [7:0] d0, d1, d2, d3;

wire [7:0] q0, q1, q2, q3;
wire wren0, wren1, wren2, wren3;

wire [BIT_WIDTH-1:0] out_word;
wire [BIT_WIDTH-1:0] out_half1, out_half0;

reg  [7:0] out_byte;
reg  [15:0] out_half;

reg read_isSigned;
reg [1:0] read_dataSize;
reg [7:0] read_addr;

/**********
 * Glue Logic
 **********/

 assign wren0 = wren && (dataSize[1] ||
					(dataSize == 2'b01) && !addr[1] ||
					addr[1:0] == 2'b00);

 assign wren1 = wren && (dataSize[1] ||
					(dataSize == 2'b01) && !addr[1] ||
					addr[1:0] == 2'b01);

 assign wren2 = wren && (dataSize[1] ||
					(dataSize == 2'b01) && addr[1] ||
					addr[1:0] == 2'b10);

 assign wren3 = wren && (dataSize[1] ||
					(dataSize == 2'b01) && addr[1] ||
					addr[1:0] == 2'b11);

/**********
 * Synchronous Logic
 **********/

always @(posedge clk) begin
	read_isSigned <= isSigned;
	read_dataSize <= dataSize;
	read_addr     <= addr;
end

/**********
 * Glue Logic
 **********/

always @* begin

	d0 <= 8'b0;
	d1 <= 8'b0;
	d2 <= 8'b0;
	d3 <= 8'b0;

	case(dataSize)
		2'b10, 2'b11 : begin //word
			d0 <= data[7:0];
			d1 <= data[15:8];
			d2 <= data[23:16];
			d3 <= data[31:24];
		end

		2'b01 : begin //half
			if(addr[1]) begin
				d2 <= data[7:0];
				d3 <= data[15:8];
			end else begin
				d0 <= data[7:0];
				d1 <= data[15:8];
			end
		end

		2'b00 : begin //byte
			case(addr[1:0])
				2'b00 : d0 <= data[7:0];
				2'b01 : d1 <= data[7:0];
				2'b10 : d2 <= data[7:0];
				2'b11 : d3 <= data[7:0];
			endcase
		end
	endcase

end

/**********
 * Components
 **********/
 ram_r0 U_MEM_0 (
	.clock(clk),
	.data(d0),
	.addr(addr[7:2]), //convert to word addressing
	.wren( wren0 ),
	.q(q0)
	);

 ram_r0 U_MEM_1 (
	.clock(clk),
	.data(d1),
	.addr(addr[7:2]),
	.wren( wren1 ),
	.q(q1)
	);

 ram_r0 U_MEM_2 (
	.clock(clk),
	.data(d2),
	.addr(addr[7:2]),
	.wren( wren2 ),
	.q(q2)
	);

 ram_r0 U_MEM_3 (
	.clock(clk),
	.data(d3),
	.addr(addr[7:2]),
	.wren( wren3 ),
	.q(q3)
	);

/**********
 * Output Combinatorial Logic
 **********/
 assign out_word = {q3, q2, q1, q0};
 assign out_half0 = {q1, q0};
 assign out_half1 = {q3, q2};

 //output selection
 always @* begin
	case(read_addr[1:0])
		2'b00 : out_byte <= q0;
		2'b01 : out_byte <= q1;
		2'b10 : out_byte <= q2;
		2'b11 : out_byte <= q3;
	endcase

	if(read_addr[1]) begin
		out_half <= out_half1;
	end else begin
		out_half <= out_half0;
	end
 end

 //extension and final selection
 always @* begin
	if(read_isSigned) begin
		case(read_dataSize)
			2'b10, 2'b11 : q <= out_word;
			2'b01 : q <= {{16{out_half[15]}}, out_half};
			2'b00 : q <= {{24{out_byte[7]}}, out_byte};
		endcase
	end else begin
		case(read_dataSize)
			2'b10, 2'b11 : q <= out_word;
			2'b01 : q <= {16'b0, out_half};
			2'b00 : q <= {24'b0, out_byte};
		endcase
	end
 end

endmodule
