`timescale 1ns / 1ps  // Bu satırı dosyanın en üstüne ekleyin

module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad;	//Output of shift left 2 unit
wire [15:0] extad_2;	//	YENI
wire [15:0] out5;
wire [31:0] out6, out7, dm_addr, jump_addr, pc_next;

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
inst10_6,	//15-11 bits of instruction		YENI
out1, out1_regdst;	//Write register (after RegDst / balpos mux)

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit

wire zout, nout, vout,	//ALU status flags (Z, N, V)
status_z, status_n, status_v,	//latched Status Register outputs
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
swv_store_en, memwrite_dm,	//swv conditional store / effective data-memory write
and_berr,	//berr & status_z & status_n & status_v
balpos_t, regwrite_e;	//balpos branch+link / effective register write

//Control signals
wire regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0, lwseq, swv, berr, balpos;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

assign swv_store_en = swv & status_v;
assign memwrite_dm  = memwrite | swv_store_en;
assign and_berr     = berr & status_z & status_n & status_v;
assign balpos_t     = balpos & (~status_z) & (~status_n);
assign regwrite_e   = regwrite | (balpos & balpos_t);
assign jump_addr    = {adder1out[31:28], instruc[25:0], 2'b00};

always @(posedge clk)
if (memwrite_dm)
begin
datmem[dm_addr[4:0]+3]=datab[7:0];
datmem[dm_addr[4:0]+2]=datab[15:8];
datmem[dm_addr[4:0]+1]=datab[23:16];
datmem[dm_addr[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst10_6=instruc[10:6];


// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
// Sadece ve sadece regwrite 1 iken saat darbesinde yazma yapmalı!
always @(posedge clk) begin
    if (regwrite_e) begin
        registerfile[out1] <= out7;
    end
end
//read data from memory
assign dpack={datmem[dm_addr[5:0]],datmem[dm_addr[5:0]+1],datmem[dm_addr[5:0]+2],datmem[dm_addr[5:0]+3]};

//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1_regdst, instruc[20:16],instruc[15:11],regdest);

//mux with balpos_t control ($31 link)
mult2_to_1_5  mult9(out1, out1_regdst, 5'b11111, balpos_t);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with swv control (ALU address vs $rs)
mult2_to_1_32 mult7(dm_addr, sum, dataa, swv);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

//mux after branch (berr / balpos jump vs normal PC path)
mult3_to_1_32 mult8(pc_next, out4, jump_addr, jump_addr, and_berr, balpos_t);

// shamt ve imm icin mux
mult2_to_1_16 mult5(out5, inst15_0, extad_2, lwseq);

//	lwseq ve balpos sinyalli mux
mult3_to_1_32 mult6(out7, out3, adder1out, out6, lwseq, balpos_t );

// load pc
always @(posedge clk)
pc=pc_next;

//	comp module
comp_module comparator(datab, out3, out6);

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,nout,vout,gout);

//Status Register (swv, berr, balpos icin)
status_register stat_reg(clk, zout, nout, vout, status_z, status_n, status_v);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0, lwseq, swv, berr, balpos, instruc[5:0]);

// Sign extender for shamt
signext_2 signext_2(inst10_6, extad_2);	//	YENI

//Sign extend unit
signext sext(out5,extad);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

//AND gate
assign pcsrc=branch && zout; 

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDM.dat", datmem);
$readmemh("initIM.dat", mem);
$readmemh("initReg.dat", registerfile);

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time," PC %h PC_NEXT %h INST %h BALPOS %b BALPOS_T %b AND_BERR %b STATUS Z=%b N=%b",
pc, pc_next, instruc[31:0], balpos, balpos_t, and_berr, status_z, status_n);
end
endmodule

