`include "defines.v"

module DataMem(input clk, MemRead, MemWrite, [2:0] F3_Load_STORE, [5:0] addr, [31:0] data_in, output reg [31:0] data_out);

    reg [7:0] mem [63:0];
    
    initial begin
    // Experiment 1
     {mem[3], mem[2], mem[1], mem[0]} = 32'd17;
     {mem[7], mem[6], mem[5], mem[4]} = 32'd9;
     {mem[11], mem[10], mem[9], mem[8]} = 32'd25;
    ////Experiment 2
    // mem[0]=32'd1;
    // mem[1]=32'd2; 
    // mem[2]=32'd3; 
    
    end
    
    always@(posedge clk) begin
        if(MemWrite)
            case(F3_Load_STORE)
                `STORE_SB:  mem[addr] = data_in[7:0];   
                `STORE_SH:  {mem[addr+1], mem[addr]} = data_in[15:0];
                `STORE_SW:  {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]} = data_in;
            endcase
            
    end
    
    always@ (*) begin
        if(MemRead)
            case(F3_Load_STORE)
                `LOAD_LB:   data_out = {{24{mem[addr][7]}},mem[addr]};
                `LOAD_LH:   data_out = {{16{mem[addr][15]}}, mem[addr+1], mem[addr]};
                `LOAD_LW:   data_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                `LOAD_LBU:  data_out = {24'b0, mem[addr]};
                `LOAD_LHU:  data_out = {16'b0, mem[addr+1], mem[addr]};      
            endcase
        else
            data_out = 32'b0;
    end
endmodule