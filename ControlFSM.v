module ControlFSM (clk, reset, irq, read, write, iack, ir, alu_flags,
    addr_sel, load_sel, count_sel, count_up, top_enable, alu_enable, alu_op);

input clk, reset;

// 16-bit microcode address
input irq;              // 1
input [7:0] ir;         // 8
input [2:0] alu_flags;  // 3
reg   [3:0] ustate;     // 4

// 22-bit microinstruction
output read, write, iack;                   // 3
output [1:0] addr_sel, load_sel, count_sel; // 6
output count_up, top_enable, alu_enable;    // 3
output [5:0] alu_op;                        // 6
wire   [3:0] nx_ustate;                     // 4

reg [21:0] ucode [0:65535];

assign {read, write, iack, addr_sel, load_sel, count_sel, count_up, top_enable,
        alu_enable, alu_op, nx_ustate} = ucode[ {ir, ustate, irq, alu_flags} ];

initial begin
    $readmemh("microcode.hex", ucode);
end

always @(posedge reset) begin
    if (reset)
        ustate <= 0;
end

always @(posedge clk) begin
    ustate <= nx_ustate;
end

endmodule