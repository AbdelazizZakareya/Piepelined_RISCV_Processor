module shifter(input[31:0] a, [4:0] shamt, [2:0] type, output reg [31:0] r);
    integer i;
    always@(*) begin
        r  = a;
        for(i = 0 ; i < shamt ; i = i + 1)
        begin
        case(type)
              2'b00:  r = {r[31], r[31:1]};
              2'b01:  r = {1'b0, r[31:1]};
              2'b10:  r = {r[30:0], 1'b0};
        endcase
        end
    end
endmodule

module n_bit_ShiftLeft_1 #(parameter n = 32) (input [n-1:0] A, output [n-1:0] B);
	assign B = {A[n-2:0], 1'b0};
endmodule

module n_bit_ShiftLeft_12 #(parameter n = 32) (input [n-1:0] A, output [n-1:0] B);
	assign B = {A[n-13:0], 12'b0};
endmodule