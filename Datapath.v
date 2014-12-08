module Datapath (clk, reset, addr, data, read, write, irq, iack);

input  clk, reset, irq;
inout  [15:0] data;
output [15:0] addr;
output read, write, iack;

reg  [15:0] top, next;
reg  [15:0] pc, dsp, rsp;
reg   [7:0] ir;

wire  [1:0] addr_sel, load_sel, count_sel;
wire        top_enable, alu_enable, count_up;
wire  [5:0] alu_op;

wire [15:0] alu_q;
wire  [2:0] alu_flags;

ControlFSM control (clk, reset, irq, read, write, iack, ir, alu_flags,
    addr_sel, load_sel, count_sel, count_up, top_enable, alu_enable, alu_op);

BitsliceALU alu (top, next, alu_op, alu_q, alu_flags);

// infer two 16-bit tri-state buffers
assign
    data = (top_enable == 1) ? top : 16'bZ,
    data = (alu_enable == 1) ? alu_q : 16'bZ;

// infer 16-bit 4-way mux
assign addr = (addr_sel == 0) ? top :
              (addr_sel == 1) ? dsp :
              (addr_sel == 2) ? rsp :
              (addr_sel == 3) ? pc  :
                                16'bX; 

// implement asynchronous reset for all registers
always @(posedge reset or posedge iack) begin
    if (reset) begin
        top  <= 0;
        next <= 0;
        dsp  <= 16'h7e00;
        rsp  <= 16'h7c00;
        ir   <= 0;
    end
    if (reset | iack) begin
        pc <= 16'h0000;
    end
end
        
// infer 2 2-to-4 decoders
// infer 3 16-bit registers with clock enable
// infer 1 16-bit up counter with clock enable and synchronous load
// infer 2 16-bit up-down counters with clock enable
always @(posedge clk) begin
    case (load_sel)
        0:       top  <= data;
        1:       next <= data;
        2:       ir   <= data[7:0];
        3:       pc   <= data;
    endcase

    case (count_sel)
        1: dsp <= count_up ? dsp + 1 : dsp - 1;
        2: rsp <= count_up ? rsp + 1 : rsp - 1;
        3: if (load_sel != 3) pc <= pc + 1;
    endcase   
end

endmodule