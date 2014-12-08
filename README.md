stack16
=======

A simple 16-bit stack machine, designed to be implemented with only 7400-series devices.

There are two 16-bit data registers named TOP and NEXT, and an 8-bit instruction register, implemented as flip-flops with clock enable inputs.

A 16-bit program counter and 15-bit data and return stack pointers are implemented as up/down counters with clock enables. Their values are not directly accessible. On a processor reset (or, for the program counter, on an interrupt), they are loaded from DIP switches.

Memory access is word-aligned. This is not especially efficient, unless I come up with a clever instruction set encoding that makes procedure calls and integer literals take only one word.

During every microinstruction cycle:
 * The address bus is driven by either the TOP register, the program counter, the data stack pointer, or the return stack pointer. 
 * The data bus is driven by either the program counter, the result of an ALU operation on the TOP and the NEXT registers, or memory. 
 * Memory may be written to if it is not being read from.
 * The TOP register, the NEXT register, the program counter, or the instruction register may be loaded from the data bus.
 * One counter may be incremented or decremented.
 * The next microstate is loaded into a 4-bit register from microprogram memory.

A 64K word x 24 bit EEPROM stores the microprogram.
 * 4 of the address bits are driven by the present microstate (limiting the length of any instruction to a maximum of 16 cycles).
 * 8 are driven by the instruction register.
 * 3 are driven by the "flag" outputs of the ALU (sign, zero, and carry).
 * 1 is driven by the IRQ pin.
This is not especially efficient, but it minimizes chip count.

The simulation requires Mark C. Hansen's Verilog behavioral model of the 74181 4-bit ALU, available [here] <http://web.eecs.umich.edu/~jhayes/iscas.restore/> for research use. If you have curl installed, 'make deps' will automatically download it.