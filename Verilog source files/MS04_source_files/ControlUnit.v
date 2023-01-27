`include "defines.v"

module Control_Unit (input bit20, [`IR_opcode] OPCODE, output reg Branch, MemRead, MemWrite, ALUSrc, RegWrite, Ebreak, UnconditionalJump, reg[1:0] WriteRegMUX, ALUOp);
    always@(*) begin
        case (OPCODE)
            `OPCODE_Arith_R: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b0;          
                RegWrite = 1'b1; 
                Ebreak = 1'b0;
                UnconditionalJump = 1'b0;
                WriteRegMUX = 2'b00; //rd = ALU_Result
                ALUOp = 2'b10; //General    
            end
            `OPCODE_Load: begin
                 Branch = 1'b0;
                 MemRead = 1'b1;
                 MemWrite = 1'b0;
                 ALUSrc = 1'b1;
                 RegWrite = 1'b1;
                 Ebreak = 1'b0;
                 UnconditionalJump = 1'b0;
                 WriteRegMUX = 2'b01; //rd = Read Data from Memory
                 ALUOp = 2'b00; //For loads and stores
            end
            `OPCODE_Store: begin
                 Branch = 1'b0;
                 MemRead = 1'b0;
                 MemWrite = 1'b1;
                 ALUSrc = 1'b1;
                 RegWrite = 1'b0;
                 WriteRegMUX = 2'b00; //Doesn't matter RegWrite = 0
                 Ebreak = 1'b0;
                 UnconditionalJump = 1'b0;
                 WriteRegMUX = 2'b01; //rd = Read Data from Memory
                 ALUOp = 2'b00; //For loads and stores
            end
            `OPCODE_Branch: begin
                 Branch = 1'b1;
                 MemRead = 1'b0;
                 MemWrite = 1'b0;
                 ALUSrc = 1'b0;
                 RegWrite = 1'b0;
                 WriteRegMUX = 2'b00; //Doesn't matter RegWrite = 0
                 Ebreak = 1'b0;
                 UnconditionalJump = 1'b0;
                 ALUOp = 2'b01; //For Branch        
            end 
            `OPCODE_LUI: begin  //LUI: rd = imm << 12
                 Branch = 1'b0;
                 MemRead = 1'b0;
                 MemWrite = 1'b0;
                 ALUSrc = 1'b1; //Imm
                 RegWrite = 1'b1;
                 WriteRegMUX = 2'b00; //Doesn't matter RegWrite = 0
                 Ebreak = 1'b0;
                 UnconditionalJump = 1'b0;
                 ALUOp = 2'b10; //General                       
            end
            `OPCODE_JAL: begin  // JAL: PC = PC + imm << 1; rd = PC + 4;
                Branch = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b1; //Imm
                RegWrite = 1'b1;
                WriteRegMUX = 2'b10; //rd = PC + 4;
                Ebreak = 1'b0;
                UnconditionalJump = 1'b0;
                ALUOp = 2'b10; //General 
            end
            `OPCODE_JALR: begin // JAL: PC = rs + imm; rd = PC + 4;
                Branch = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b1; //Imm
                RegWrite = 1'b1;
                WriteRegMUX = 2'b10; //rd = PC + 4;
                Ebreak = 1'b0;
                UnconditionalJump = 1'b0;
                ALUOp = 2'b10; //General
            end
            `OPCODE_Arith_I: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b1; //Imm
                RegWrite = 1'b1;
                WriteRegMUX = 2'b00; //rd = PC + 4;
                Ebreak = 1'b0;
                UnconditionalJump = 1'b0;
                ALUOp = 2'b11; //Arithmetic I
            end
            `OPCODE_AUIPC: begin // rd = PC + imm << 12;
                 Branch = 1'b0;
                 MemRead = 1'b0;
                 MemWrite = 1'b0;
                 ALUSrc = 1'b1; //Imm
                 RegWrite = 1'b1;
                 WriteRegMUX = 2'b11; //rd = PC + imm << 12;
                 Ebreak = 1'b0;
                 UnconditionalJump = 1'b0;
                 ALUOp = 2'b00; //Don't Care
            end
            `OPCODE_SYSTEM: begin
                 Branch = 1'b0;
                 MemRead = 1'b0;
                 MemWrite = 1'b0;
                 ALUSrc = 1'b0; //Don't Care
                 RegWrite = 1'b0;
                 WriteRegMUX = 2'b00; //Don't Care
                 ALUOp = 2'b00; //Don't Care       
                 if(bit20) begin
                    Ebreak = 1'b1;
                    UnconditionalJump = 1'b0;
                 end 
                 else begin
                     Ebreak = 1'b0;
                     UnconditionalJump = 1'b1;
                 end   
            end
            `OPCODE_FENCE: begin
                Branch = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUSrc = 1'b0; //Don't Care
                RegWrite = 1'b0;
                WriteRegMUX = 2'b00; //Don't Care
                Ebreak = 1'b0;
                UnconditionalJump = 1'b1;
                ALUOp = 2'b11; //Don't Care
            end
        endcase
    end
endmodule
