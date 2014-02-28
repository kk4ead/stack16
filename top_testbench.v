module Top (clk, reset);

input clk, reset;

Datapath CPU (clk, irq, reset, addr, data, read, write);

endmodule