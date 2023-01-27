module RISCVPipeline (input clk,input  clk_bcd, input rst, input [1:0] ledSel, 
    input [3:0] ssdSel, output [6:0] LED_out, output[7:0] Anode, output reg [15:0] led);
    wire Branch, BranchOutcome, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, IF_ID_Load, zf, cf, sf, vf,
    memReadInstructionData, memWriteInstructionData, stall, break, call_fence, ImmMux;
    wire [1:0] ALUOp, ForwardA, ForwardB, WriteRegMUXSel;
    wire[2:0] F3_Load__Store;
    wire [31:0] WriteData, ReadData1, ReadData2, ReadData, Imm, ALUResult, MUX_ALU, ShiftLeft_1_Out, PC4, MUX_ADD, IR, ALUA, ALUB, TargetAddressAdder,
    ShiftLeft_12_Out, PCMUXOUTPUT, AUIPCAdder, IR_ReadData, memAddress;
    reg [31:0] PC;
    wire [3:0] ALU_Sel;
    reg [12:0] SSD;
    wire [4:0] shamt;
    assign PC4 = PC + 4;
    assign TargetAddressAdder = PC + Imm;
    assign shamt = ALUSrc ? IR_ReadData[24:20] : ReadData2;
    //IF_ID
    wire [31:0] IF_ID_PC, IF_ID_IR;
    //ID_EX
    wire [31:0] ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm;
    wire ID_EX_Branch, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite;
    wire [1:0] ID_EX_ALUOp;
    wire [3:0] ID_EX_Func;
    wire [4:0] ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd;
    //EX_MEM
    wire [31:0] EX_MEM_BranchAddOut, EX_MEM_ALU_out, EX_MEM_RegR2;
    wire EX_MEM_Branch, EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_RegWrite;
    wire [2:0] EX_MEM_F3_LOAD_STORE;
    wire [4:0] EX_MEM_Rd;
    wire EX_MEM_Zero;
    //MEM_WB
    wire MEM_WB_MemtoReg, MEM_WB_RegWrite;
    wire [31:0] MEM_WB_Mem_out, MEM_WB_ALU_out;
    wire [4:0] MEM_WB_Rd;
    
    //Instruction Memory and Data Memory in One Memory
    mux_2x1 memoryAddressMUX(clk, EX_MEM_ALU_out[5:0], PC[5:0] + 32, memAddress);
    assign memReadInstructionData = clk ? (1'b1) : (EX_MEM_MemRead);
    assign memWriteInstructionData = clk ? (1'b0) : (EX_MEM_MemWrite);
    assign F3_Load__Store = clk ? (3'b010) : (EX_MEM_F3_LOAD_STORE);
    Memory MM (clk, memReadInstructionData, memWriteInstructionData, F3_Load__Store, memAddress[5:0], EX_MEM_RegR2, IR_ReadData);
    //Hazard Detection Unit
    HazardDetectionUnit HZ(ID_EX_MemRead, IF_ID_IR [19:15],  IF_ID_IR [24:20], ID_EX_Rd, stall);
    //IF_ID
    assign IF_ID_Load = stall ? 1'b0 : 1'b1;
    n_bit_register #(64) IF_ID({PC, IR}, rst, IF_ID_Load, ~clk, {IF_ID_PC,IF_ID_IR});
    //Resgister File
    registerFile #(32) RF (~clk, rst , MEM_WB_RegWrite, IF_ID_IR [19:15], IF_ID_IR [24:20], MEM_WB_Rd, WriteData, ReadData1, ReadData2);  
    //Control Unit
    Control_Unit CU(stall, IR_ReadData[6:2], Branch, MemRead, MemWrite, ALUSrc, RegWrite, ImmMux, break, call_fence, WriteRegMUXSel, ALUOp);
    //ID_EX
    n_bit_register #(155) ID_EX({Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp, IF_ID_PC, ReadData1,
    ReadData2, Imm, IF_ID_IR[30], IF_ID_IR[14:12],IF_ID_IR[19:15], IF_ID_IR[24:20], IF_ID_IR[11:7]}, rst, 1'b1, clk, {ID_EX_Branch,
    ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite, ID_EX_ALUSrc, ID_EX_RegWrite,
    ID_EX_ALUOp, ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_Func, ID_EX_Rs1, ID_EX_Rs2, ID_EX_Rd});
    //Immediate Generator
    ImmGen IG (IF_ID_IR, Imm);
    //ALU Control Unit
    ALU_ControlUnit ACU (ID_EX_Func[3], ID_EX_ALUOp, ID_EX_Func[2:0], ALU_Sel);
    //Forwarding Unit
    ForwardingUnit FWU(EX_MEM_RegWrite, MEM_WB_RegWrite, ID_EX_Rs1, ID_EX_Rs2,
    EX_MEM_Rd, MEM_WB_Rd, ForwardA, ForwardB);
    //4X1 Muxes
    mux_4x1 MUXALUA(ID_EX_RegR1, MEM_WB_Mem_out, EX_MEM_ALU_out, ID_EX_RegR1, ForwardA, ALUA);
    mux_4x1 MUXALUB(ID_EX_RegR2, MEM_WB_Mem_out, EX_MEM_ALU_out, ID_EX_RegR2, ForwardB, ALUB);
    //ALU
    N_bit_ALU #(32) NALU (ALUA, MUX_ALU, shamt, ALU_Sel, cf, zf, vf, sf, ALUResult);
    //EX_MEM
    n_bit_register #(200) EX_MEM({ID_EX_Branch, ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite,
    ID_EX_RegWrite, TargetAddressAdder, zf, ALUResult, ALUB, ID_EX_Func[2:0], ID_EX_Rd}, rst, 1'b1, ~clk, {EX_MEM_Branch, EX_MEM_MemRead,
    EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_RegWrite, EX_MEM_BranchAddOut, EX_MEM_Zero, EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_F3_LOAD_STORE, EX_MEM_Rd});
    //MEM_WB
    n_bit_register #(200) MEM_WB({EX_MEM_MemtoReg, EX_MEM_RegWrite, ReadData, EX_MEM_ALU_out, EX_MEM_Rd},
    rst, 1'b1, clk, {MEM_WB_MemtoReg, MEM_WB_RegWrite, MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Rd});
    //Different Multiplexers
    
    mux_4x1 WriteDataMux(ALUResult, ReadData, PC4, TargetAddressAdder, WriteRegMUXSel, WriteData);
    mux_2x1 ALUMUX(ID_EX_ALUSrc, ALUB, ID_EX_Imm, MUX_ALU);
    branching BR(zf, cf, sf, vf, Branch, IR[6:2], IR[14:12], BranchOutcome);
    mux_4x1 PCMUX(PC4, PC4, ALUResult, TargetAddressAdder, {BranchOutcome,Branch}, PCMUXOUTPUT);
    
    always@(posedge clk or posedge rst) begin
        if (rst || call_fence) PC = 0;
        else if(stall || break)
            PC = PC;
        else
            PC = PCMUXOUTPUT;
    end
//     LED and SSD output case statements
    always@(*) begin
        case (ledSel)
            2'b00: led = IR[15:0];
            2'b01: led = IR[31:16];
            2'b10: led = {2'b00, ALUOp, ALU_Sel, zf, (Branch & zf), Branch, MemRead, MemWrite, ALUSrc, RegWrite, MemtoReg};
            default: led = 0;
        endcase
    end
    
    always@(*) begin
        case (ssdSel)
            4'b0000: SSD = PC;
            4'b0001: SSD = PC4;
            4'b0010: SSD = TargetAddressAdder;
            4'b0011: SSD = MUX_ADD;
            4'b0100: SSD = ReadData1;
            4'b0101: SSD = ReadData2;
            4'b0110: SSD = WriteData;
            4'B0111: SSD = Imm;
            4'b1000: SSD = ShiftLeft_1_Out;
            4'b1001: SSD = MUX_ALU;
            4'b1010: SSD = ALUResult;
            4'b1011: SSD = ReadData;
            default: SSD = 0;
        endcase 
    end
    BCD bcd (clk_bcd, SSD,LED_out, Anode);
endmodule