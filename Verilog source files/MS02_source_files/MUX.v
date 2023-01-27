module mux_2x1(input s, [31:0] a, b, output [31:0] out);
    assign out = s?b:a;
endmodule

module mux_4x2(input[31:0] a, b, c, d, [1:0] s, output reg [31:0] out);
    always@(*) begin
        case(s)
           2'b00: out = a;
           2'b01: out = b;
           2'b10: out = c;
           2'b11: out = d;
        endcase
    end
endmodule