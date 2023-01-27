`include "defines.v"
module RISCVPipeline (input clk,input  clk_bcd, input rst, input [1:0] ledSel, 
input [3:0] ssdSel, output [6:0] LED_out, output[7:0] Anode, output reg [15:0] led);
    wire [31:0] WriteData, ReadData1, ReadData2, ReadData, Imm, ALUResult, MUX_ALU_OUTPUT,
        ShiftLeft_1_Out, PC4, MUX_ADD, ALUA, ALUB, TargetAddressAdderOut, ShiftLeft_12_Out, PCMUXOUTPUT,
        AUIPCAdder, IR_ReadData, memAddress;
    wire Branch, BranchOutcome, MemRead, MemWrite, ALUSrc, RegWrite, zf, cf, sf, vf,
    memReadInstructionData, memWriteInstructionData, Ebreak, UnconditionalJump, bit20,
    BranchFlushed, MemReadFlushed, MemWriteFlushed, ALUSrcFlushed, RegWriteFlushed;
    wire [1:0] ALUOp, ALUOpFlushed, WriteRegMUXSel, WriteRegMUXSelFlushed, PC_MUX_Sel, ForwardA, ForwardB;
    wire [2:0] F3_Load_Store;
    reg [31:0] PC;
    wire [3:0] ALU_Sel;
    reg [12:0] SSD;
    wire [4:0] shamt;
    //PC + 4 Adder
    assign PC4 = PC + 4;
    //IF_ID
    wire [31:0] IF_ID_PC, IF_ID_IR, IF_ID_PC4;
    //ID_EX
    wire [31:0] ID_EX_PC, ID_EX_ReadR1, ID_EX_ReadR2, ID_EX_Imm, ID_EX_PC4;
    wire [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_OPCODE;
    wire [2:0] ID_EX_Func3;
    wire [1:0] ID_EX_ALUOp, ID_EX_WriteRegMUXSel;
    wire ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite, ID_EX_bit30;
    //EX_MEM
    wire [31:0] EX_MEM_TargetAddressAdderOut, EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_PC4;
    wire [4:0] EX_MEM_Rd, EX_MEM_OPCODE;
    wire [2:0] EX_MEM_F3;
    wire [1:0] EX_MEM_WriteRegMUXSel;
    wire EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_RegWrite, EX_MEM_cf, 
    EX_MEM_zf, EX_MEM_vf, EX_MEM_sf;
    //MEM_WB
    wire [31:0] MEM_WB_TargetAddressAdderOut, MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_PC4;
    wire [4:0] MEM_WB_Rd;
    wire [1:0] MEM_WB_WriteRegMUXSel;
    wire MEM_WB_MemRead, MEM_WB_RegWrite;
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                    //Instruction Fetching Cycle (IF)
    //PC MUX
    assign PC_MUX_Sel = {BranchOutcome, EX_MEM_Branch};
    mux_4x1 PCMUX(PC4, PC4, EX_MEM_ALU_out, EX_MEM_TargetAddressAdderOut, PC_MUX_Sel, PCMUXOUTPUT);
    //Instruction Memory and Data Memory in One Memory
    mux_2x1 memoryAddressMUX(clk, EX_MEM_ALU_out[5:0], PC[5:0] + 32, memAddress);
    assign memReadInstructionData = clk ? (1'b1) : (EX_MEM_MemRead);
    assign memWriteInstructionData = clk ? (1'b0) : (EX_MEM_MemWrite);
    assign F3_Load_Store = clk ? (3'b010) : (EX_MEM_F3);
    Memory MM (~clk, memReadInstructionData, memWriteInstructionData, F3_Load_Store, memAddress[5:0], EX_MEM_RegR2, IR_ReadData);
    //IF_ID
    n_bit_register #(96) IF_ID({PC, IR_ReadData, PC4}, rst, 1'b1, ~clk, {IF_ID_PC, IF_ID_IR, IF_ID_PC4});
    //------------------------------------------------------------------------------------------
                                    //Instruction Decoding Cycle (ID)
    //Resgister File
    registerFile #(32) RF (~clk, rst, MEM_WB_RegWrite, IF_ID_IR [19:15], IF_ID_IR [24:20], MEM_WB_Rd, WriteData, ReadData1, ReadData2);  
    //Control Unit
    assign bit20 = IF_ID_IR[20];
    Control_Unit CU(bit20, IF_ID_IR[6:2], Branch, MemRead, MemWrite, ALUSrc, RegWrite, Ebreak, UnconditionalJump, WriteRegMUXSel, ALUOp);
    //Immediate Generator
    ImmGen IG (IF_ID_IR, Imm);
    //MUX for flushing
    assign {Branch, MemRead, MemWrite, ALUSrc, RegWrite, WriteRegMUXSel, ALUOp} = (PC_MUX_Sel == (2'b11)) ? 0 :
    {BranchFlushed, MemReadFlushed, MemWriteFlushed, ALUSrcFlushed, RegWriteFlushed, WriteRegMUXSelFlushed, ALUOpFlushed};
    //ID_EX
    n_bit_register #(200) ID_EX ({BranchFlushed, MemReadFlushed, MemWriteFlushed, ALUSrcFlushed, RegWriteFlushed, WriteRegMUXSelFlushed, ALUOpFlushed,
    PC, ReadData1, ReadData2, Imm, IF_ID_IR[30], IF_ID_IR[14:12], IF_ID_IR[19:15], IF_ID_IR[24:20], IF_ID_IR[11:7], IF_ID_IR[6:2], IF_ID_PC4},
    rst, 1'b1, clk, {ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite, ID_EX_WriteRegMUXSel, ID_EX_ALUOp,
    ID_EX_PC, ID_EX_ReadR1, ID_EX_ReadR2, ID_EX_Imm, ID_EX_bit30, ID_EX_Func3, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd, ID_EX_OPCODE, ID_EX_PC4});
    //------------------------------------------------------------------------------------------
                                    //Instruction Execution Cycle (EX)
    //ALU Control Unit
    ALU_ControlUnit ACU (ID_EX_bit30, ID_EX_ALUOp, ID_EX_Func3, ALU_Sel);
    //Forwarding Unit
    ForwardingUnit FWU(MEM_WB_RegWrite, MEM_WB_MemRead, ID_EX_Rs1, ID_EX_Rs2,
    MEM_WB_Rd, ForwardA, ForwardB);
    //2 2X1 Muxes for forwarding
    mux_4x1 MUXALUA(ID_EX_ReadR1, MEM_WB_Mem_out, MEM_WB_ALU_out, 32'd0, ForwardA, ALUA);
    mux_4x1 MUXALUB(ID_EX_ReadR2, MEM_WB_Mem_out, MEM_WB_ALU_out, 32'd0, ForwardB, ALUB);
    //ALU MUX
    mux_2x1 ALUMUX(ID_EX_ALUSrc, ALUB, ID_EX_Imm, MUX_ALU_OUTPUT);
    //ALU
    N_bit_ALU #(32) NALU (ALUA, MUX_ALU_OUTPUT, shamt, ALU_Sel, cf, zf, vf, sf, ALUResult);
    //Target Address Adder
    assign TargetAddressAdderOut = ID_EX_PC + ID_EX_Imm;
    //shamt
    assign shamt = ID_EX_ALUSrc ? ID_EX_Rs2 : ID_EX_ReadR2;
    //EX_MEM
    n_bit_register #(200) EX_MEM({ID_EX_Branch, ID_EX_MemRead, ID_EX_MemWrite,
    ID_EX_RegWrite, WriteRegMUXSel, TargetAddressAdderOut, cf, zf, vf, sf, ALUResult, ALUB,
    ID_EX_Func3, ID_EX_Rd, ID_EX_OPCODE, ID_EX_PC4}, rst, 1'b1, ~clk,
    {EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_RegWrite, EX_MEM_WriteRegMUXSel,
    EX_MEM_TargetAddressAdderOut, EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf, EX_MEM_ALU_out,
    EX_MEM_RegR2, EX_MEM_F3, EX_MEM_Rd, EX_MEM_OPCODE, EX_MEM_PC4});    
    //------------------------------------------------------------------------------------------
                                        //Instruction Memory Cycle (MEM)
    branching BR(EX_MEM_cf, EX_MEM_zf, EX_MEM_vf, EX_MEM_sf, EX_MEM_Branch, EX_MEM_OPCODE, EX_MEM_F3, BranchOutcome);
    //MEM_WB
    n_bit_register #(200) MEM_WB({EX_MEM_WriteRegMUXSel, EX_MEM_RegWrite, IR_ReadData, EX_MEM_ALU_out, EX_MEM_Rd, EX_MEM_TargetAddressAdderOut, EX_MEM_PC4, EX_MEM_MemRead},
    rst, 1'b1, clk, {MEM_WB_WriteRegMUXSel, MEM_WB_RegWrite, MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Rd, MEM_WB_TargetAddressAdderOut, MEM_WB_PC4, MEM_WB_MemRead});
    //------------------------------------------------------------------------------------------
                                        //Instruction Write Back Cycle (WB)
    //Write Reg MUX
    mux_4x1 WriteDataMux(MEM_WB_ALU_out, MEM_WB_Mem_out, MEM_WB_PC4, MEM_WB_TargetAddressAdderOut, MEM_WB_WriteRegMUXSel, WriteData);       
    always@(posedge clk or posedge rst) begin
        if (rst || UnconditionalJump) PC = 32'd0;
        else if(Ebreak)
            PC = PC;
        else
            PC = PCMUXOUTPUT;
    end
    //LED and SSD output case statements
    always@(*) begin
        case (ledSel)
            2'b00: led = IR_ReadData[15:0];
            2'b01: led = IR_ReadData[31:16];
            2'b10: led = {1'b0, ALUOp, ALU_Sel, zf, (Branch & zf), Branch, MemRead, MemWrite, ALUSrc, RegWrite, WriteRegMUXSel};
            default: led = 0;
        endcase
    end
    
    always@(*) begin
        case (ssdSel)
            4'b0000: SSD = PC;
            4'b0001: SSD = PC4;
            4'b0010: SSD = TargetAddressAdderOut;
            4'b0011: SSD = MUX_ADD;
            4'b0100: SSD = ReadData1;
            4'b0101: SSD = ReadData2;
            4'b0110: SSD = WriteData;
            4'B0111: SSD = Imm;
            4'b1000: SSD = ShiftLeft_1_Out;
            4'b1001: SSD = MUX_ALU_OUTPUT;
            4'b1010: SSD = ALUResult;
            4'b1011: SSD = ReadData;
            default: SSD = 0;
        endcase 
    end
    BCD bcd (clk_bcd, SSD,LED_out, Anode);
endmodule