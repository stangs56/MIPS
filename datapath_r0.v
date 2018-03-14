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
	//note: all in ID stage
	//delayed versions created as needed

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

	/**********
	 * Data Forwarding
	 **********/

wire [1:0] df_forwardA, df_forwardB;

/**********
 * Fetch
 **********/

	//PC
	wire [ADDR_WIDTH-1:0] PC_out;
	wire [ADDR_WIDTH-1:0] PC_in;
	wire [ADDR_WIDTH-1:0] PC_plus4;
	wire PC_plus4_ovf;

	//program memory
	wire [5:0] progMemIn;

/**********
 * Decode
 **********/


 wire [ADDR_WIDTH-1:0] id_PC_out;
 //Branch
  wire [ADDR_WIDTH-1:0] PC_branchTmp;

  wire [ADDR_WIDTH-1:0] PC_branchMux;

  wire PC_branchTmp_ovf;
	wire id_reg_eq;

	//instruction split
	wire [BIT_WIDTH-1:0] id_instruction;

	wire [OP_WIDTH-1:0] id_opcode;
	wire [REG_ADDR_WIDTH-1:0] id_rs, id_rt, id_rd;
	wire [IMM_WIDTH-1:0] id_immediate;
	wire [SHAMT_WIDTH-1:0] id_shamt;
	wire [FUNCT_WIDTH-1:0] id_funct;
	wire [BIT_WIDTH-OP_WIDTH-1:0] id_jConst;

	//registers
	wire [REG_ADDR_WIDTH-1:0] id_regToWrite;
	wire [REG_ADDR_WIDTH-1:0] id_regRead [1:0];
	wire [2*REG_ADDR_WIDTH-1:0] id_rr_tmp;
	wire [2*BIT_WIDTH-1:0] id_q_tmp;
	wire [BIT_WIDTH-1:0] id_readData [1:0];
	wire [BIT_WIDTH-1:0] id_regWriteData;

	//sign extender
	wire [BIT_WIDTH-1:0] id_imm_extended;

/**********
 * Execute
 **********/
	//Data forwarding
	wire [BIT_WIDTH-1:0] ex_alu_in_df;

	//registers
	wire [BIT_WIDTH-1:0] ex_readData [1:0];
	wire [REG_ADDR_WIDTH-1:0] ex_regToWrite;
	wire [REG_ADDR_WIDTH-1:0] ex_rs, ex_rt;

  //control
  wire [FUNCT_WIDTH-1:0] ex_funct;
	wire [SHAMT_WIDTH-1:0] ex_shamt;
  wire [ALUOP_WIDTH-1:0] ex_ALUop;
	wire ex_ALUsrc;

	//ALU
	wire [ALUFUNCT_WIDTH-1:0] ex_ALUfunct;
	wire [BIT_WIDTH-1:0] ex_ALUDataIn [1:0];
	wire [2*BIT_WIDTH-1:0] ex_ALUDataIn_tmp;

	//sign extender
	wire [BIT_WIDTH-1:0] ex_imm_extended;

/**********
 * Memory
 **********/

 wire [REG_ADDR_WIDTH-1:0] mem_regToWrite;
 //control
 wire mem_memWrite;
 wire mem_memIsSigned;
 wire [1:0] mem_memDataSize;

 //mem
 wire [STATUS_WIDTH-1:0] mem_status;
 wire [BIT_WIDTH-1:0] mem_ALUDataOut;
 wire [BIT_WIDTH-1:0] mem_regData;
 wire mem_C, mem_Z, mem_S, mem_V;

/**********
 * writeback
 **********/

	wire [BIT_WIDTH-1:0] wb_dataMemOut;
	wire [BIT_WIDTH-1:0] wb_out;
	wire [BIT_WIDTH-1:0] wb_ALUDataOut;

	wire [REG_ADDR_WIDTH-1:0] wb_regToWrite;

/**********
 * Glue Logic
 **********/

 //instruction splitting
 assign id_opcode = id_instruction[31:26];
 assign id_rs = id_instruction[25:21];
 assign id_rt = id_instruction[20:16];
 assign id_rd = id_instruction[15:11];
 assign id_shamt = id_instruction[10:6];
 assign id_funct = id_instruction[5:0];
 assign id_immediate = id_instruction[15:0];
 assign id_jConst    = id_instruction[25:0];

 //branching
 assign id_reg_eq = id_readData[0] == id_readData[1];
 assign branchTaken = (eq && branch && id_reg_eq) || (!eq && branch && !id_reg_eq);

 //renaming
 assign mem_C = mem_status[3];
 assign mem_Z = mem_status[2];
 assign mem_S = mem_status[1];
 assign mem_V = mem_status[0];

 //register renaming
 assign id_regRead[1] = id_rt;
 assign id_regRead[0] = id_rs;

 //array packing
 `PACK_ARRAY(REG_ADDR_WIDTH, 2, id_regRead, id_rr_tmp, U_BLK_0, idx_0)
 `UNPACK_ARRAY(BIT_WIDTH, 2, id_readData, id_q_tmp, U_BLK_1, idx_1)


 `PACK_ARRAY(BIT_WIDTH, 2, ex_ALUDataIn, ex_ALUDataIn_tmp, U_BLK_2, idx_2)

/**********
 * Synchronous Logic
 **********/
/**********
 * Glue Logic
 **********/
 assign clk_mem = clk;
 assign clk_sys = clk;
/**********
 * Components
 **********/
 /**********
  * Data Fowarding
  **********/
 data_forwarding_unit_r0 #(
	 .BIT_WIDTH(BIT_WIDTH),
	 .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
	 .DELAY(0)
 )U_DATA_FORWARDING_UNIT(
	 .clk(clk),
	 .rst(rst),

	 .rs(ex_rs),
	 .rt(ex_rt),

	 .mem_writeReg(mem_writeReg),
	 .mem_regToWrite(mem_regToWrite),

	 .wb_writeReg(wb_writeReg),
	 .wb_regToWrite(wb_regToWrite),

	 .forwardA(df_forwardA),
	 .forwardB(df_forwardB)
 );

 /**********
 * Fetch
 **********/

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
		 {id_PC_out[31:28], id_jConst, 2'b0},
		 {id_PC_out[31:28], id_jConst, 2'b0},
		 mem_ALUDataOut, //needs to be from registers
		 PC_branchMux}),
	 .sel({jump || jal, jr}),
	 .dataOut(PC_in)
 );

 	delay #(
		.BIT_WIDTH(BIT_WIDTH),
		.DEPTH(1),
		.DELAY(1),
		.ARCH_SEL(0)
	)U_PC(
		.clk(clk),
		.rst(rst),
		.en_n(1'b0),
		.dataIn(PC_in),
		.dataOut(PC_out)
	);

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

	mux #(
 	 .BIT_WIDTH(6),
 	 .DEPTH(2),
 	 .ARCH_SEL(0)
  )U_PROG_MEM_FORCE_RST(
 	 .clk(clk_sys),
 	 .rst(rst),
 	 .en_n(1'b0),
 	 .dataIn({6'b0, PC_in[7:2]}),
 	 .sel(rst),
 	 .dataOut(progMemIn)
  );

 //address has register (uses that instead of normal PC)
 programMem U_PROGRAM_MEMORY(
		.address(progMemIn),
		.clock(clk_mem),
		.q(id_instruction) //output has register
	);

 /**********
 * IF/ID
 **********/

 delay #(
	 .BIT_WIDTH(ADDR_WIDTH),
	 .DEPTH(1),
	 .DELAY(1),
	 .ARCH_SEL(0)
 )U_IF_ID_PC_DELAY(
	 .clk(clk),
	 .rst(rst),
	 .en_n(1'b0),
	 .dataIn(PC_out),
	 .dataOut(id_PC_out)
 );

 /**********
 * Decode
 **********/

  //controller stuff
  	controller #(
		.OP_WIDTH(OP_WIDTH),
		.ALUOP_WIDTH(ALUOP_WIDTH),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_CONTROLLER(
		.clk(clk_sys),
		.rst(rst),
		.opcode(id_opcode),
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

  //register file stuff
	 registerFile #(
	  .DATA_WIDTH(BIT_WIDTH),
	  .RD_DEPTH(2),
	  .REG_DEPTH(32),
	  .ARCH_SEL(0)
	)U_REGFILE(
	  .clk(clk_sys),
	  .rst(rst),
	  .jal(jal),
	  .wr(wb_regWrite),
	  .rr(id_rr_tmp),
	  .rw(wb_regToWrite),
	  .d(id_regWriteData),
	  .q(id_q_tmp)
	);

	mux #(
	  .BIT_WIDTH(REG_ADDR_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_REG_DEST_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({id_rd, id_rt}),
	  .sel(regDest),
	  .dataOut(id_regToWrite)
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
		.dataIn(id_immediate),
		.dataOut(id_imm_extended)
	);

	//branch address calculation
	adder #(
		.BIT_WIDTH(BIT_WIDTH),
		.DELAY(DELAY),
		.ARCH_SEL(0)
	)U_PC_BRANCH_ADD(
		.clk(clk_sys),
		.rst(rst),
		.inA(PC_out),
		.inB({id_imm_extended[BIT_WIDTH-3:0], 2'b0}), //left shift by 2
		.out({PC_branchTmp_ovf, PC_branchTmp})
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
	  .dataIn({PC_plus4 + 4, wb_out}),
	  .sel(jal),
	  .dataOut(id_regWriteData)
	);


 /**********
 * ID/EX
 **********/

 delay #(
	 .BIT_WIDTH(ALUOP_WIDTH + FUNCT_WIDTH + SHAMT_WIDTH + 1),
	 .DEPTH(1),
	 .DELAY(1),
	 .ARCH_SEL(0)
 )U_ID_EX_CONTROL_DELAY(
	 .clk(clk),
	 .rst(rst),
	 .en_n(1'b0),
	 .dataIn({id_funct, id_shamt, ALUop, ALUsrc}),
	 .dataOut({ex_funct, ex_shamt, ex_ALUop, ex_ALUsrc})
 );

 delay #(
 .BIT_WIDTH(REG_ADDR_WIDTH),
 .DEPTH(3),
 .DELAY(1),
 .ARCH_SEL(0)
 )U_ID_EX_REGWRITE_DELAY(
 .clk(clk),
 .rst(rst),
 .en_n(1'b0),
 .dataIn({id_regToWrite, id_rs, id_rt}),
 .dataOut({ex_regToWrite, ex_rs, ex_rt})
 );

 delay #(
	 .BIT_WIDTH(BIT_WIDTH),
	 .DEPTH(3),
	 .DELAY(1),
	 .ARCH_SEL(0)
 )U_ID_EX_IMM_DELAY(
	 .clk(clk),
	 .rst(rst),
	 .en_n(1'b0),
	 .dataIn({id_imm_extended, id_readData[1], id_readData[0]}),
	 .dataOut({ex_imm_extended, ex_readData[1], ex_readData[0]})
 );

 /**********
 * Execute
 **********/

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
		.funct(ex_funct),
		.ALUop(ex_ALUop),
		.ALUfunct(ex_ALUfunct),
		.jr(jr)
	);

	mux #(
		.BIT_WIDTH(BIT_WIDTH),
		.DEPTH(3),
		.ARCH_SEL(0)
	)U_ALU_IN1_DF_MUX(
		.clk(clk_sys),
		.rst(rst),
		.en_n(1'b0),
		.dataIn({wb_out, mem_ALUDataOut, ex_readData[0]}),
		.sel(df_forwardA),
		.dataOut(ex_ALUDataIn[0])
	);

	mux #(
		.BIT_WIDTH(BIT_WIDTH),
		.DEPTH(3),
		.ARCH_SEL(0)
	)U_ALU_IN2_DF_MUX(
		.clk(clk_sys),
		.rst(rst),
		.en_n(1'b0),
		.dataIn({wb_out, mem_ALUDataOut, ex_readData[1]}),
		.sel(df_forwardB),
		.dataOut(ex_alu_in_df)
	);

	mux #(
	  .BIT_WIDTH(BIT_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_ALU_IN2_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({ex_imm_extended, ex_alu_in_df}),
	  .sel(ex_ALUsrc),
	  .dataOut(ex_ALUDataIn[1])
	);

	 alu #(
		.DATA_WIDTH(BIT_WIDTH),
		.CTRL_WIDTH(ALUFUNCT_WIDTH),
		.STATUS_WIDTH(STATUS_WIDTH),
		.SHAMT_WIDTH(SHAMT_WIDTH),
		.DELAY(1),
		.ARCH_SEL(0)
	)U_ALU(
		.clk(clk_sys),
		.rst(rst),
		.dataIn(ex_ALUDataIn_tmp),
		.ctrl(ex_ALUfunct),
		.shamt(ex_shamt),
		.dataOut(mem_ALUDataOut),
		.status(mem_status)
	);

 /**********
 * EX/MEM
 **********/

 delay #(
	.BIT_WIDTH(BIT_WIDTH),
	.DEPTH(1),
	.DELAY(1),
	.ARCH_SEL(0)
 )U_EX_MEM_REG_DATA_DELAY(
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(ex_alu_in_df),
	.dataOut(mem_regData)
 );

 delay #(
 .BIT_WIDTH(REG_ADDR_WIDTH),
 .DEPTH(1),
 .DELAY(1),
 .ARCH_SEL(0)
 )U_EX_MEM_REGWRITE_DELAY(
 .clk(clk),
 .rst(rst),
 .en_n(1'b0),
 .dataIn(ex_regToWrite),
 .dataOut(mem_regToWrite)
 );

 delay #(
	.BIT_WIDTH(4),
	.DEPTH(1),
	.DELAY(2),
	.ARCH_SEL(0)
 )U_ID_MEM_CONTROL_DELAY(
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn({memWrite, memIsSigned, memDataSize}),
	.dataOut({mem_memWrite, mem_memIsSigned, mem_memDataSize})
 );

 /**********
 * Memory
 **********/

 	dataRAM U_DATA_MEMORY(
		.clk(~clk_mem),
		.data(mem_regData),
		.addr(mem_ALUDataOut[7:0]),
		.wren(mem_memWrite),
		.isSigned(mem_memIsSigned),
		.dataSize(mem_memDataSize),
		.q(wb_dataMemOut)
	);

 /**********
 * MEM/WB
 **********/

 delay #(
	.BIT_WIDTH(BIT_WIDTH),
	.DEPTH(1),
	.DELAY(1),
	.ARCH_SEL(0)
 )U_MEM_WB_ALUOUT_DELAY(
	.clk(clk),
	.rst(rst),
	.en_n(1'b0),
	.dataIn(mem_ALUDataOut),
	.dataOut(wb_ALUDataOut)
 );

 delay #(
 .BIT_WIDTH(REG_ADDR_WIDTH),
 .DEPTH(1),
 .DELAY(1),
 .ARCH_SEL(0)
 )U_MEM_WB_REGWRITE_DELAY(
 .clk(clk),
 .rst(rst),
 .en_n(1'b0),
 .dataIn(mem_regToWrite),
 .dataOut(wb_regToWrite)
 );

 delay #(
 .BIT_WIDTH(2),
 .DEPTH(1),
 .DELAY(3),
 .ARCH_SEL(0)
 )U_ID_WB_CONTROL_DELAY(
 .clk(clk),
 .rst(rst),
 .en_n(1'b0),
 .dataIn({memToReg, regWrite}),
 .dataOut({wb_memToReg, wb_regWrite})
 );

 /**********
 * Write Back
 **********/

 	mux #(
	  .BIT_WIDTH(BIT_WIDTH),
	  .DEPTH(2),
	  .ARCH_SEL(0)
	)U_MEM2REG_MUX(
	  .clk(clk_sys),
	  .rst(rst),
	  .en_n(1'b0),
	  .dataIn({wb_dataMemOut, wb_ALUDataOut}), //update
	  .sel(wb_memToReg),
	  .dataOut(wb_out)
	);


/**********
 * Output Combinatorial Logic
 **********/
endmodule
