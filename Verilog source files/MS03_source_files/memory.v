`include "defines.v"

module Memory(input clk, MemRead, MemWrite, [2:0] F3_Load_STORE, [5:0] addr, [31:0] data_in, output reg [31:0] data_out);

    reg [7:0] mem [63:0];
    
    initial begin
    // Experiment 1 Data Memory
     {mem[3], mem[2], mem[1], mem[0]} = 32'd17;
     {mem[7], mem[6], mem[5], mem[4]} = 32'd9;
     {mem[11], mem[10], mem[9], mem[8]} = 32'd25;
//    ////Experiment 2
//    // mem[0]=32'd1;
//    // mem[1]=32'd2; 
//    // mem[2]=32'd3;

    //Experiment 1 Instruction Memory
    {mem[35], mem[34], mem[33], mem[32]} = 32'b0000000_00000_00000_000_00000_0110011 ; //add x0, x0, x0
    //--------------------------------------------------------------------------------------------------
    {mem[39], mem[38], mem[37], mem[36]} = 32'b000000000000_00000_010_00001_0000011 ; //lw x1, 0(x0)
    {mem[43], mem[42], mem[41], mem[40]} = 32'b000000000100_00000_010_00010_0000011 ; //lw x2, 4(x0)
    {mem[47], mem[46], mem[45], mem[44]} = 32'b000000001000_00000_010_00011_0000011 ; //lw x3, 8(x0)
    {mem[51], mem[50], mem[49], mem[48]} = 32'b0000000_00010_00001_110_00100_0110011 ; //or x4, x1, x2
//    mem[36]=32'b0_000000_00011_00100_000_0100_0_1100011; //beq x4, x3, 4
//    mem[37]=32'b0000000_00010_00001_000_00011_0110011 ; //add x3, x1, x2
//    mem[38]=32'b0000000_00010_00011_000_00101_0110011 ; //add x5, x3, x2
//    mem[39]=32'b0000000_00101_00000_010_01100_0100011; //sw x5, 12(x0)
//    mem[40]=32'b000000001100_00000_010_00110_0000011 ; //lw x6, 12(x0)
//    mem[41]=32'b0000000_00001_00110_111_00111_0110011 ; //and x7, x6, x1
//    mem[42]=32'b0100000_00010_00001_000_01000_0110011 ; //sub x8, x1, x2
//    mem[43]=32'b0000000_00010_00001_000_00000_0110011 ; //add x0, x1, x2
//    mem[44]=32'b0000000_00001_00000_000_01001_0110011 ; //add x9, x0, x1
    
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
                `LOAD_LB:   data_out = {{24{mem[addr][7]}}, mem[addr]};
                `LOAD_LH:   data_out = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
                `LOAD_LW:   data_out = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                `LOAD_LBU:  data_out = {24'b0, mem[addr]};
                `LOAD_LHU:  data_out = {16'b0, mem[addr+1], mem[addr]};      
            endcase
        else
            data_out = 32'b0;
    end
endmodule