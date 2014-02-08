module cpu (clk, irq, reset, addr, data, read, write);

input clk, irq, reset;
output [15:0] addr;
inout [15:0] data;
output read, write;

reg [15:0] top, next, dsp, rsp, pc, ir;
reg first;
reg [7:0] state, next_state;

wire [1:0] opcode;
wire [1:0] addr_sel;
wire [1:0] data_sel;
wire [4:0] alu_op;
wire consume, conditional, swapbytes;

wire ld_top, ld_next, ld_pc, ld_ir;
wire pc_up, dsp_up, rsp_up, dsp_dn, rsp_dn;

// instruction encoding
case (first)
	1: begin
		opcode = ir[15:14];
		addr_sel = ir[13:12];
		data_sel = ir[11:10];
		consume = ir[9];
		conditional = ir[8];
		alu_op = ir[13:9];
		swapbytes = ir[8];
	end
	0: begin
		opcode = ir[7:6];
		addr_sel = ir[5:4];
		data_sel = ir[3:2];
		consume = ir[1];
		conditional = ir[0];
		alu_op = ir[5:1];
		swapbytes = ir[0];
	end
endcase

// state encoding
parameter fetch     = 9'b000000001, interrupt  = 9'b000000010,
		  decode    = 9'b000000100, exec_nop   = 9'b000001000,
		  exec_load = 9'b000010000, exec_store = 9'b000100000,
		  exec_calc = 9'b001000000, wb_load    = 9'b010000000,
		  wb_store  = 9'b100000000;

// opcode encoding
parameter calc = 2'b00, reserved = 2'b01,
		  load = 2'b10, store = 2'b11;

// address selection encoding
parameter at_top = 2'b00, at_dsp = 2'b01,
		  at_pc  = 2'b10, at_rsp = 2'b11;

// data selection encoding
parameter in_top = 2'b00, in_next = 2'b01,
		  in_pc  = 2'b10, in_ir   = 2'b11;

// state machine
case (state)
	fetch: next_state = decode;
	interrupt: next_state = decode;
	decode:
		case (opcode)
			calc:     next_state = exec_calc;
			reserved: next_state = exec_nop;
			load, store: begin
				if ( !cond || (top == 16'h0000) )
					if state == load
						next_state = exec_load;
					else
						next_state = exec_store;
				else
					next_state = exec_nop;
			end
		endcase
	exec_load:  next_state = wb_load;
	exec_store: next_state = wb_store;
	wb_load, wb_store, exec_calc, exec_reserved, exec_nop: begin
		if first:
			next_state = decode;
/*		else if irq:
			next_state = interrupt; */
		else:
			next_state = fetch;
	end
endcase

// address mux
case (state)
    fetch: addr = pc;
    // todo: implement interrupts
    exec_load, exec_store, wb_load, wb_store: case (addr_sel)
        at_top: addr = top;
        at_pc:  addr = pc;
        at_dsp: addr = dsp;
        at_rsp: addr = rsp;
    endcase
    default: addr = 16'bxxxxxxxxxxxxxxxx;
endcase

// data mux
case (state)
    /* todo: implement alu */
    exec_store, wb_store: case (data_sel)
        in_top:  data = top;
        in_next: data = next;
        in_pc:   data = pc;
        in_ir:   data = 16'bxxxxxxxxxxxxxxxx; // todo: make this more useful
    endcase
    default: data = 16'bZZZZZZZZZZZZZZZZ;
endcase

ld_top  = state == wb_load && data_sel == in_top;
ld_next = state == wb_load && data_sel == in_next;
ld_ir   = state == wb_load && data_sel == in_ir;
ld_pc   = state == wb_load && data_sel == in_pc;

pc_up   = consume && addr_sel == at_pc
          && (state == wb_load || state == wb_store);
dsp_up  = consume && addr_sel == at_dsp && state == wb_store;
rsp_up  = consume && addr_sel == at_rsp && state == wb_store;
dsp_dn  = consume && addr_sel == at_dsp && state == wb_load;
rsp_dn  = consume && addr_sel == st_rsp && state == wb_load;

always @(posedge clk) begin
	state <= next_state;
	if      (ld_top || state == exec_calc) top <= data;
	if      (ld_next) next <= data;
	if      (ld_ir || state == fetch) ir <= data;
	/* TODO: implement interrupts */	
	if      (ld_pc)   pc  <= data;
	else if (pc_up)   pc  <= pc + 16'h0001;
	if      (dsp_up)  dsp <= dsp + 1;
	else if (dsp_dn)  dsp <= dsp - 1;
	if      (rsp_up)  rsp <= rsp + 1;
    else if (rsp_dn)  rsp <= rsp - 1;
end
endmodule