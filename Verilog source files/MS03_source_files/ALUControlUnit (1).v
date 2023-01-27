`include "defines.v"

module ALU_ControlUnit (input b, [1:0] ALUOp, [2:0] F3, output reg [3:0] ALU_Sel );
    always@(*) begin
        case (ALUOp)
            2'b00: ALU_Sel = `ALU_ADD; //Loads and stores
            2'b01: ALU_Sel = `ALU_SUB; //Branches
            2'b10:  //R_type Arithmetic
            case (F3)
                `F3_ADD_SUB: ALU_Sel = (b == 0)? `ALU_ADD : `ALU_SUB;
                `F3_SLL: ALU_Sel = `ALU_SLL;
                `F3_SLT: ALU_Sel = `ALU_SLT;
                `F3_SLTU: ALU_Sel = `ALU_SLTU;
                `F3_XOR: ALU_Sel = `ALU_XOR;
                `F3_SRL_SRA: ALU_Sel = (b == 0)? `ALU_SRL : `ALU_SRA;
                `F3_OR: ALU_Sel = `ALU_OR;
                `F3_AND: ALU_Sel = `ALU_AND;
              endcase
            2'b11:  //I-type Arithmetic
            case (F3)
                `F3_ADD_SUB: ALU_Sel = `ALU_ADD;
                `F3_SLL: ALU_Sel = `ALU_SLL;
                `F3_SLT: ALU_Sel = `ALU_SLT;
                `F3_SLTU: ALU_Sel = `ALU_SLTU;
                `F3_XOR: ALU_Sel = `ALU_XOR;
                `F3_SRL_SRA: ALU_Sel = (b == 0)? `ALU_SRL : `ALU_SRA;
                `F3_OR: ALU_Sel = `ALU_OR;
                `F3_AND: ALU_Sel = `ALU_AND;
            endcase 
        endcase
    end
endmodule
