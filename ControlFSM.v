module ControlFSM (clk, reset, read, write, irq, iack, ir, addr_sel, alu_oper, data_from_alu, alu_flags, top_clken, top_from_next, next_clken, next_from_top, ir_clken, pc_clken, pc_load, dsp_clken, dsp_up, rsp_clken, rsp_up);

input clk, irq, reset;
input [15:0] ir;
input  [2:0] alu_flags; // { Carry, Zero, Minus1 }

output read, write, iack;
output [1:0] addr_sel; // 0=PC, 1=DSP, 2=RSP, 3=ALU
output [5:0] alu_oper;  // { M, S3..S0, Swap }
output data_from_alu;
output top_clken, top_from_next, next_clken, next_from_top;
output ir_clken, pc_clken, pc_load, dsp_clken, dsp_up, rsp_clken, rsp_up;

reg pr_state, nx_state;

endmodule