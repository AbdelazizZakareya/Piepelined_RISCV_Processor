`timescale 1ns / 1ps


module SIM(    );
parameter CLK_P = 100;
reg clk, clk_bcd, rst;
reg [1:0] ledSel;
reg [3:0] ssdSel;
wire[6:0] LED_out;
wire[7:0] Anode;
wire[15:0] led;

initial begin
    clk = 1'b0;
    forever begin
        #(CLK_P/2) clk = ~clk;
    end
end


SINGLE_CYCLE_CPU cpu(clk, clk_bcd, rst, ledSel, ssdSel, LED_out, Anode, led);

initial begin
    rst = 1'b1;#10;
    rst = 1'b0;
end

endmodule
