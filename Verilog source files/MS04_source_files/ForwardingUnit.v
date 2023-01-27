module ForwardingUnit(input  MEM_WB_RegWrite, MEM_WB_MemRead, [4:0] ID_EX_RegisterRs1, ID_EX_RegisterRs2,
MEM_WB_RegisterRd, output reg[1:0] ForwardA, ForwardB);
// 01 --> MemOut, 10 --> ALUOut, 00 --> Normal 
    always@(*) begin
        if (MEM_WB_RegWrite && MEM_WB_MemRead &&
        MEM_WB_RegisterRd != 0 && MEM_WB_RegisterRd == ID_EX_RegisterRs1)
            ForwardA = 2'b01;
        else if(MEM_WB_RegWrite && !MEM_WB_MemRead &&
        MEM_WB_RegisterRd != 0 && MEM_WB_RegisterRd == ID_EX_RegisterRs1)
            ForwardA = 2'b10;
        else
            ForwardA = 2'b00;
        if (MEM_WB_RegWrite && MEM_WB_MemRead && MEM_WB_RegisterRd != 0
        && MEM_WB_RegisterRd == ID_EX_RegisterRs2)
            ForwardB = 2'b01;
        else if (MEM_WB_RegWrite && !MEM_WB_MemRead && MEM_WB_RegisterRd != 0
        && MEM_WB_RegisterRd == ID_EX_RegisterRs2)
            ForwardB = 2'b10;
        else
            ForwardB = 2'b0;
    end
endmodule
