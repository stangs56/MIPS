/*
DESCRIPTION

NOTES

TODO

*/

module datapath_r0 #(
	parameter BIT_WIDTH = 32,
	parameter ADDR_WIDTH = 32,	
	parameter DELAY = 0
)(
	input  clk,
	input  rst,
	input  rst_clk
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

	parameter OP_WIDTH = 6;
	parameter ALUOP_WIDTH = 6;
	parameter FUNCT_WIDTH = 6;
	parameter ALUFUNCT_WIDTH = 6;
	parameter REG_ADDR_WIDTH = 5;
	parameter SHAMT_WIDTH = 5;
	parameter IMM_WIDTH = 16;
	parameter STATUS_WIDTH = 4;
	
	//clocks
	wire clk_sys;
	wire clk_mem;
	
	//control signals from controller
	
	wire [ALUOP_WIDTH-1:0] ALUop;
	
	wire regWrite;
	wire regDest;
	wire memToReg;
	
	wire load_upper;
	wire isSigned;
	wire ALUsrc;
	
	wire jump;
	wire jal;
	wire branch;
	wire eq;
	
	wire memRead;
	wire memWrite;
	
	wire memIsSigned;
	wire [1:0] memDataSize;
	
	wire [ALUOP_WIDTH+9-1:0] combined;
	
	wire jr;
	
	//control signals created in datapath
	wire branchTaken;
	wire C, Z, S, V;
	
	//PC
	wire [ADDR_WIDTH-1:0] PC_out;
	wire [ADDR_WIDTH-1:0] PC_in;
	wire [ADDR_WIDTH-1:0] PC_plus4;
	wire [ADDR_WIDTH-1:0] PC_branchTmp;
	
	wire [ADDR_WIDTH-1:0] PC_branchMux;
	
	wire PC_plus4_ovf, PC_branchTmp_ovf;
	
	reg  [ADDR_WIDTH-1:0] PC; //replace with PC component
	
	//instruction split
	wire [BIT_WIDTH-1:0] instruction;
	
	wire [OP_WIDTH-1:0] opcode;
	wire [REG_ADDR_WIDTH-1:0] rs, rt, rd;
	wire [IMM_WIDTH-1:0] immediate;
	wire [SHAMT_WIDTH-1:0] shamt;
	wire [FUNCT_WIDTH-1:0] funct;
	wire [BIT_WIDTH-OP_WIDTH-1:0] jConst;
	
	//registers
	wire [REG_ADDR_WIDTH-1:0] regToWrite;
	wire [BIT_WIDTH-1:0] regWriteData;
	wire [REG_ADDR_WIDTH-1:0] regRead [1:0];
	wire [2*REG_ADDR_WIDTH-1:0] rr_tmp;
	wire [2*BIT_WIDTH-1:0] q_tmp;
	wire [BIT_WIDTH-1:0] readData [1:0];
	
	//sign extender
	wire [BIT_WIDTH-1:0] imm_extended;
	
	//ALU
	wire [ALUFUNCT_WIDTH-1:0] ALUfunct;
	wire [STATUS_WIDTH-1:0] status;
	wire [BIT_WIDTH-1:0] ALUDataIn [1:0];
	wire [2*BIT_WIDTH-1:0] ALUDataIn_tmp;
	wire [BIT_WIDTH-1:0] ALUDataOut;
	
	//writeback
	wire [BIT_WIDTH-1:0] dataMemOut;
	wire [BIT_WIDTH-1:0] wbOut;

/**********
 * Glue Logic 
 **********/
 
 //instruction splitting
 assign opcode = instruction[31:26];
 assign rs = instruction[25:21];
 assign rt = instruction[20:16];
 assign rd = instruction[15:11];
 assign shamt = instruction[10:6];
 assign funct = instruction[5:0];
 assign immediate = instruction[15:0];
 assign jConst    = instruction[25:0];
 
 //renaming
 assign ALUDataIn[0] = readData[0];
 assign branchTaken = (eq && branch && Z) || (!eq && branch && !Z);
 assign C = status[3];
 assign Z = status[2];
 assign S = status[1];
 assign V = status[0];
 
 //register renaming
 assign regRead[1] = rt;
 assign regRead[0] = rs;
 
 //array packing
 `PACK_ARRAY(REG_ADDR_WIDTH, 2, regRead, rr_tmp, U_BLK_0, idx_0)
 `UNPACK_ARRAY(BIT_WIDTH, 2, readData, q_tmp, U_BLK_1, idx_1)
 
 
 `PACK_ARRAY(BIT_WIDTH, 2, ALUDataIn, ALUDataIn_tmp, U_BLK_2, idx_2)
 
/**********
 * Synchronous Logic
 **********/
 
 //replace
 always @(posedge clk_sys) begin
	if(rst) begin
		PC <= 0;
	end else begin
		PC <= PC_in;
	end
 end
 
/**********
 * Glue Logic 
 **********/
 assign PC_out = PC; //replace
 assign clk_mem = clk;
/**********
 * Components
 **********/
 
 //clock stuff
 
 //divide clock by 6
	clk_div #(
		.IN_FREQ(6),
		.OUT_FREQ(1),
		.ARCH_SEL(0)
	)U_CLK_DIV(
		.clk(clk),
		.rst(rst_clk),
		.new_clk(clk_sys)
	);
	
	
	//memory stuff
	programMem U_PROGRAM_MEMORY(
		.address(PC_out[7:2]),
		.clock(clk_mem),
		.q(instruction)
	);
	
	dataRAM U_DATA_MEMORY(
		.clk(clk_mem),
		.data(readData[1]),
		.addr(ALUDataOut[7:2]), //convert to word addressing
		.wren(memWrite),
		.isSigned(memIsSigned),
		.dataSize(memDataSize),
		.q(dataMemOut)
	);
	
 
 //PC stuff
  	adder #(
		.BIT_WIDTH(BIT_WIDTH),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_PC_ADDER(
		.clk(clk_sys),
		.rst(rst),
		.inA(PC_out),
		.inB(4),
		.out({PC_plus4_ovf, PC_plus4})
	);
	
	adder #(
		.BIT_WIDTH(BIT_WIDTH),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_PC_BRANCH_ADD(
		.clk(clk_sys),
		.rst(rst),
		.inA(PC_out),
		.inB({imm_extended[BIT_WIDTH-3:0], 2'b0}), //left shift by 2
		.out({PC_branchTmp_ovf, PC_branchTmp})
	);
	
	mux #(
	  .BIT_WIDTH(BIT_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_PC_BRANCH_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({PC_branchTmp, PC_plus4}),
	  .sel(branchTaken),
	  .dataOut(PC_branchMux)
	);
	
	//picks between branch and jumps
	mux #(
	  .BIT_WIDTH(BIT_WIDTH),
	  .DEPTH(4),
	  .ARCH_SEL(0)
	)U_PC_JUMP_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({
			{PC_out[31:28], jConst, 2'b0}, 
			{PC_out[31:28], jConst, 2'b0}, 
			ALUDataOut, PC_branchMux}),
	  .sel({jump || jal, jr}),
	  .dataOut(PC_in)
	);
 
 
 //register file stuff
	 registerFile #(
	  .DATA_WIDTH(BIT_WIDTH),
	  .RD_DEPTH(2),
	  .REG_DEPTH(32),
	  .ARCH_SEL(0)
	)U_REGFILE(
	  .clk(~clk_sys),
	  .rst(rst),
	  .jal(jal),
	  .wr(regWrite),
	  .rr(rr_tmp),
	  .rw(regToWrite),
	  .d(regWriteData),
	  .q(q_tmp)
	);
	
	mux #(
	  .BIT_WIDTH(REG_ADDR_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_REG_DEST_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({rd, rt}),
	  .sel(regDest),
	  .dataOut(regToWrite)
	);
	
	//for jal
	mux #(
	  .BIT_WIDTH(BIT_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_REG_WRITE_PC(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({PC_plus4 + 4, wbOut}),
	  .sel(jal),
	  .dataOut(regWriteData)
	);

	//controller stuff
  	controller #(
		.OP_WIDTH(OP_WIDTH),
		.ALUOP_WIDTH(ALUOP_WIDTH),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_CONTROLLER(
		.clk(clk_sys),
		.rst(rst),
		.opcode(opcode),
		.ALUop(ALUop),
		.regWrite(regWrite),
	   .regDest(regDest),
	   .memToReg(memToReg),
		
		.load_upper(load_upper),
	   .isSigned(isSigned),
		.ALUsrc(ALUsrc),
	
		.jump(jump),
		.jal(jal),
		.branch(branch),
		.eq(eq),
	
		.memRead(memRead),
		.memWrite(memWrite),
		
		.memIsSigned(memIsSigned),
		.memDataSize(memDataSize),
		
		.combined(combined)
	);
	
	//sign extender stuff
	 sign_extend #(
		.BIT_WIDTH_IN(IMM_WIDTH),
		.BIT_WIDTH_OUT(BIT_WIDTH),
		.DEPTH(1),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_SIGN_EXTEND(
		.clk(clk_sys),
		.rst(rst),
		.is_signed(isSigned),
		.load_upper(load_upper),
		.dataIn(immediate),
		.dataOut(imm_extended)
	);
	
	//ALU stuff
	
	 ALU_controller #(
		.FUNCT_WIDTH(FUNCT_WIDTH),
		.ALUOP_WIDTH(ALUOP_WIDTH),
		.ALUFUNCT_WIDTH(ALUFUNCT_WIDTH),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_ALU_CONTROLLER(
		.clk(clk_sys),
		.rst(rst),
		.funct(funct),
		.ALUop(ALUop),
		.ALUfunct(ALUfunct),
		.jr(jr)
	);
	
	mux #(
	  .BIT_WIDTH(BIT_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_ALU_IN2_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({imm_extended, readData[1]}),
	  .sel(ALUsrc),
	  .dataOut(ALUDataIn[1])
	);
	
	 alu #(
		.DATA_WIDTH(BIT_WIDTH),
		.CTRL_WIDTH(ALUFUNCT_WIDTH),
		.STATUS_WIDTH(STATUS_WIDTH),
		.SHAMT_WIDTH(SHAMT_WIDTH),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_ALU(
		.clk(clk_sys),
		.rst(rst),
		.dataIn(ALUDataIn_tmp),
		.ctrl(ALUfunct),
		.shamt(shamt), 
		.dataOut(ALUDataOut),
		.status(status)
	);
	
	//Writeback
	mux #(
	  .BIT_WIDTH(BIT_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_MEM2REG_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({dataMemOut, ALUDataOut}), //update
	  .sel(memToReg),
	  .dataOut(wbOut)
	);
 
/**********
 * Output Combinatorial Logic
 **********/
endmodule
