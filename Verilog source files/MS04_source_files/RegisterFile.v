`timescale 1ns / 1ps

module DFlipFlop(input clk, input rst, input D, output reg Q);
    always @ (posedge clk or posedge rst)
    begin
        if (rst) begin
            Q <= 1'b0;
        end else begin
            Q <= D;
         end
    end
endmodule

module mux(input A, input B, input S, output C);
    assign C = (~S & A) | (S & B);
endmodule

module n_bit_register #(parameter n = 8) (input [n-1:0] D, input rst, input Load, input clk, output [n-1:0] Q);

genvar i;
wire[n-1:0] DD;
generate
	for(i = 0; i < n; i = i+1) begin: myblockname
		mux m( Q[i],D[i],  Load, DD[i]);
		DFlipFlop dflpflop(clk, rst, DD[i], Q[i]);	
    end
endgenerate
endmodule

module registerFile #(parameter n = 8) (input clk, rst , RegWrite, [4:0] ReadReg1, ReadReg2, WriteReg, [n-1:0] WriteData, output reg [n-1:0] ReadData1, ReadData2);
  
  wire [n-1:0] Q [31:0];
  reg [31:0] load;

always@(*)
begin
    load = 32'd0;
    load [WriteReg] = (WriteReg)? RegWrite : 0;
end

always@(*)
begin
    ReadData1 = Q [ReadReg1];
    ReadData2 = Q [ReadReg2];
end

genvar i;  
generate
    for (i = 0; i < 32; i = i+1) begin: myblockname
       n_bit_register #(32) nb(WriteData, rst, load[i], clk,  Q[i]);
    end
endgenerate
endmodule
