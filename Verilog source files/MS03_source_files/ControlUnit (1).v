`include "defines.v"

module Control_Unit (input stall, [`IR_opcode] OPCODE, output reg Branch, MemRead, MemWrite, ALUSrc, RegWrite, ImmMux, break, call_fence, reg[1:0] WriteRegMUX, ALUOp);
    always@(*) begin
        if(stall) begin
               Branch = 1'b0;
               MemRead  = 1'b0;
               WriteRegMUX = 2'b00;
               ALUOp = 2'b00;
               ALUSrc = 1'b0;
               MemWrite = 1'b0;
               RegWrite = 1'b0;
           end
        else begin
            case (OPCODE)
                `OPCODE_Arith_R: begin
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    WriteRegMUX = 2'b00; //rd = ALU_Result
                    ALUOp = 2'b10; //General
                    ALUSrc = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
                end
                `OPCODE_Load: begin
                     Branch = 1'b0;
                     MemRead = 1'b1;
                     WriteRegMUX = 2'b01; //rd = Read Data
                     ALUOp = 2'b00; //For loads and stores
                     ALUSrc = 1'b1;
                     MemWrite = 1'b0;
                     RegWrite = 1'b1;
                end
                `OPCODE_Store: begin
                     Branch = 1'b0;
                     MemRead = 1'b0;
                     WriteRegMUX = 2'b00; //Doesn't matter RegWrite = 0
                     ALUOp = 2'b00; //For loads and stores
                     ALUSrc = 1'b1;
                     MemWrite = 1'b1;
                     RegWrite = 1'b0;
                end
                `OPCODE_Branch: begin
                     Branch = 1'b1;
                     MemRead = 1'b0;
                     WriteRegMUX = 2'b00; //Doesn't matter RegWrite = 0
                     ALUOp = 2'b01; //For Branch
                     ALUSrc = 1'b0;
                     MemWrite = 1'b0;
                     RegWrite = 1'b0;
                end 
                `OPCODE_LUI: begin  //LUI: rd = imm << 12
                     Branch = 1'b0;
                     MemRead = 1'b0;
                     WriteRegMUX = 2'b00; //Doesn't matter RegWrite = 0
                     ALUOp = 2'b10; //General
                     ALUSrc = 1'b1; //Imm
                     MemWrite = 1'b0;
                     RegWrite = 1'b1;
                end
                `OPCODE_JAL: begin  // JAL: PC = PC + imm << 1; rd = PC + 4;
                    Branch = 1'b1;
                    MemRead = 1'b0;
                    WriteRegMUX = 2'b10; //rd = PC + 4;
                    ALUOp = 2'b10; //General
                    ALUSrc = 1'b1; //Imm
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
                end
                `OPCODE_JALR: begin // JAL: PC = rs + imm; rd = PC + 4;
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    WriteRegMUX = 2'b10; //rd = PC + 4;
                    ALUOp = 2'b10; //General
                    ALUSrc = 1'b1; //Imm
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
                end
                `OPCODE_Arith_I: begin
                    Branch = 1'b0;
                    MemRead = 1'b0;
                    WriteRegMUX = 2'b00; //rd = PC + 4;
                    ALUOp = 2'b11; //Arithmetic I
                    ALUSrc = 1'b1; //Imm
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;
            end
                `OPCODE_AUIPC: begin // rd = PC + imm << 12;
                     Branch = 1'b0;
                     MemRead = 1'b0;
                     WriteRegMUX = 2'b11; //rd = PC + imm << 12;
                     ALUOp = 2'b11; //Doesn't matter
                     ALUSrc = 1'b1; //Imm
                     MemWrite = 1'b0;
                     RegWrite = 1'b1;
            end
    //            `OPCODE_SYSTEM: begin
    //                Branch = 1'b1;
    //                MemRead  = 1'b0;
    //                MemtoReg = 1'b0;
    //                ALUOp = 2'b01;
    //                ALUSrc = 1'b0;
    //                MemWrite = 1'b0;
    //                RegWrite = 1'b0;
    //        end
    //            `OPCODE_Custom: begin
    //                Branch = 1'b1;
    //                MemRead  = 1'b0;
    //                MemtoReg = 1'b0;
    //                ALUOp = 2'b01;
    //                ALUSrc = 1'b0;
    //                MemWrite = 1'b0;
    //                RegWrite = 1'b0;
    //        end
            endcase
        end
    end
endmodule
