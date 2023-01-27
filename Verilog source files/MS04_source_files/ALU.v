`include "defines.v"

module  N_bit_ALU #(parameter n = 32) (input [n-1:0] a, b, [4:0]shamt, [3:0] sel, output cf, zf, vf, sf, reg [n-1:0] r);
    wire [31:0] add_sub, op_b, shiftOutput;
    assign op_b = ~b;
    assign {cf, add_sub} = sel[0] ? (a + op_b + 1'b1) : (a + b);
    assign zf = (add_sub == 0);
    assign sf = add_sub[31];
    assign vf = (a[31] ^ op_b[31] ^ add_sub[31] ^ cf);
    
    shifter shift0(a, shamt, sel[1:0], shiftOutput);  
    
    always@(*)
    begin
        case (sel)
            `ALU_ADD: r = add_sub;
            `ALU_SUB: r = add_sub;
            `ALU_PASS: r = b;
            `ALU_OR: r = a | b;
            `ALU_AND: r = a & b;
            `ALU_XOR: r = a ^ b;
            `ALU_SRL: r = shiftOutput;
            `ALU_SRA: r = shiftOutput;
            `ALU_SLL: r = shiftOutput;
            `ALU_SLT: r = {31'b0, (sf != vf)};
            `ALU_SLTU: r = {31'b0, (~cf)};
        endcase
    end
endmodule