
module SINGLE_CYCLE_CPU(input clk, clk_bcd, rst, [1:0] ledSel, [3:0] ssdSel, output [6:0] LED_out, [7:0] Anode, reg [15:0] led);
    wire [31:0] IR, WriteData, ReadData1, ReadData2, ReadData, Imm, ALUResult, MUX_ALU, TargetAddressAdder, ShiftLeft_1_Out, PC4, PCMUXOUTPUT, ShiftLeft_12_Out, AUIPCAdder;
    wire Branch, BranchOutcome, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ImmMux, zf, cf, sf, vf;
    wire [1:0] WriteRegMUXSel, ALUOp;
    wire [3:0] ALU_Sel;
    reg [31:0] PC;
    reg [12:0] SSD;
    assign PC4 = PC + 4;
    assign TargetAddressAdder = PC + ShiftLeft_1_Out;
    assign AUIPCAdder = PC + ShiftLeft_12_Out;
    // 00 -> PC + 4;
    // 11 -> PC + imm
    // 01 -> PC + 4;
    // 10 -> 
    InstMem IM (PC[7:2], IR);
    Control_Unit CU(IR[6:2], Branch, MemRead, MemWrite, ALUSrc, RegWrite, ImmMux, WriteRegMUXSel, ALUOp);
    registerFile #(32) RF (clk, rst , RegWrite, IR[19:15], IR[24:20], IR[11:7], WriteData, ReadData1, ReadData2);
    ImmGen IG (IR, Imm);
    ALU_ControlUnit ACU (IR[30], ALUOp, IR[14:12], ALU_Sel);
    N_bit_ALU #(32) NALU(ReadData1, MUX_ALU, IR[24:20], ALU_Sel, cf, zf, vf, sf, ALUResult);
    DataMem DM (clk, MemRead, MemWrite, IR[14:12], ALUResult[5:0], ReadData2, ReadData);
    n_bit_ShiftLeft_1 #(32) SL1 (Imm, ShiftLeft_1_Out);
    BCD bcd (clk_bcd, SSD,LED_out, Anode);
    
    mux_4x2 WriteDataMux(ALUResult, ReadData, PC4, AUIPCAdder, WriteRegMUXSel, WriteData);
    mux_2x1 ALUMUX(ALUSrc, ReadData2, Imm, MUX_ALU);
    branching BR(zf, cf, sf, vf, Branch, IR[6:2], IR[14:12], BranchOutcome);
    mux_4x2 PCMUX(PC4, PC4, ALUResult, TargetAddressAdder, {BranchOutcome,Branch}, PCMUXOUTPUT);
    n_bit_ShiftLeft_12 #(32) SL12(Imm, ShiftLeft_12_Out);
    
    always@(posedge clk or posedge rst) begin
        if (rst) PC = 0;
        else PC = PCMUXOUTPUT;
    end
    
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
            4'b0011: SSD = PCMUXOUTPUT;
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
endmodule