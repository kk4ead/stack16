module Datapath (clk, reset, addr, data, read, write, irq, iack);

input clk, irq, reset;
output [15:0] addr;
inout [15:0] data;
output read, write;

reg [15:0] top, next, dsp, rsp, pc, ir;
reg [7:0] dsp_low, rsp_low;

wire [1:0] addr_sel;  // 0=PC, 1=DSP, 2=RSP, 3=ALU
wire [5:0] alu_oper;  // { M, S3..S0, Swap }
wire [2:0] alu_flags; // { Carry, Zero, Minus1 }
wire [15:0] alu_A, alu_B, alu_Q;

BitsliceALU alu (alu_A, alu_B, alu_oper[5:1], alu_oper[0], alu_Q, alu_flags[2], alu_flags[1], alu_flags[0]);

ControlFSM control (clk, reset, read, write, irq, iack, ir, addr_sel, alu_oper, data_from_alu, alu_flags, top_clken, top_from_next, next_clken, next_from_top, ir_clken, pc_clken, pc_load, dsp_clken, dsp_up, rsp_clken, rsp_up);

// infer 16-bit tri-state buffer
assign data = data_from_alu ? alu_Q : 16'bZZZZZZZZZZZZZZZZ;

assign dsp = { 8'hff, dsp_low }; // data stack grows upward from 16'hff00
assign rsp = { 8'hff, rsp_low }; // return stack grows downward from 16'hffff

// infer 16-bit 4-way mux
always begin
    case (addr_sel)
        0:
            address = pc;
        1:
            address = dsp;
        2:
            address = rsp;
        default:
            address = alu_Q; // use top instead? faster, but less flexible
    endcase
end

// asynchronous reset for all registers
always @(reset) begin
    if (reset) begin
        top <= 0;
        next <= 0;
        dsp_low <= 0;
        rsp_low <= -1;
        pc <= 0;
        ir <= 0;
    end
end
        
// infer 2 16-bit 2-way muxes
// infer 3 16-bit registers with clock enable
// infer 1 16-bit up counter with clock enable and synchronous load
// infer 2  8-bit up-down counters with clock enable
always @(posedge clk) begin
    if (top_clken)  top  <= top_from_next ? next : data;
    if (next_clken) next <= next_from_top ? top  : data;
    if (ir_clken)   ir   <= data;
    if (pc_clken)   pc   <= pc_load ? data : pc + 1;
    if (dsp_clken)  dsp  <= dsp_up ? dsp + 1 : dsp - 1;
    if (rsp_clken)  rsp  <= rsp_up ? rsp + 1 : rsp - 1;
end

endmodule