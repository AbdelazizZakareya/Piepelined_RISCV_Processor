`include "defines.v"

module branching(input cf, zf, vf, sf, Branch, [6:2] Opcode, [2:0] F3_Branch, output reg BranchOutcome);  
    always@(*) begin
        case (Opcode)
            `OPCODE_Branch:
                    if(Branch)
                        case(F3_Branch)
                            `BR_BEQ: BranchOutcome = zf;
                            `BR_BNE: BranchOutcome = ~zf;
                            `BR_BLT: BranchOutcome = (sf != vf);
                            `BR_BGE: BranchOutcome = (sf == vf);
                            `BR_BLTU: BranchOutcome = ~cf;
                            `BR_BGEU: BranchOutcome = cf;
                         endcase
                    else
                        BranchOutcome = 1'b0;
             `OPCODE_JAL:
                    BranchOutcome = 1'b1;
              `OPCODE_JAL:
                    BranchOutcome = 1'b1;
              default: BranchOutcome = 1'b0;
        endcase
    end
endmodule
