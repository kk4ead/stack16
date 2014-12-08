//assign {read, write, iack, addr_sel, load_sel, count_sel, count_up, top_en,
//        alu_enable, alu_op, nx_ustate} = ucode[{ir, ustate, irq, alu_flags}];
// WATCH OUT, alu_flags is not registered!

#ifndef MICROCODE_H
#define MICROCODE_H

// ********** TODO: Define the instruction set

// ********** Define the microcode address encoding
enum ADDR_OFFSETS {
    alu_zero,           // 1 bit
    alu_sign,           // 1 bit
    alu_carry,          // 1 bit
    irq,                // 1 bit
    ustate,             // 4 bits
    ir = ustate + 4     // 8 bits
};               // total 16 bits

const unsigned int  ALU_ZERO    = 1 << alu_zero,
                    ALU_SIGN    = 1 << alu_sign,
                    ALU_CARRY   = 1 << alu_carry,
                    IRQ         = 1 << irq;

#define USTATE(x)   ((x & 0x0f) << ustate)
#define OPCODE(x)   ((x & 0xff) << ir)

// ********** Define useful ALU operations
enum ALU_FUNCTIONS {
    // pass-throughs
    TOP, NEXT,
    // logic functions
    AND, OR, XOR, NOT, /* NOT_NEXT, */ NAND, NOR, XNOR,
    // arithmetic functions
    ADD, SUB, SHL, INC, DEC,
    // constants
    ZERO, MINUS_1
};

// As defined in TI's SN74LS181 datasheet.
// "top" is wired to input A, "next" is wired to input B
const unsigned int ALU_OPCODES[] = {
                  //MSSSSCn
    [INC]       = 0b000000, // top + 1
    [ADD]       = 0b000011, // top + next
    [MINUS_1]   = 0b000111, // -1
    [SUB]       = 0b001100, // top - next
    [SHL]       = 0b011001, // top + top
    [DEC]       = 0b011111, // top - 1
    [NOT]       = 0b100000, // (top)'
    [NOR]       = 0b100010, // (top | next)'
    [ZERO]      = 0b100110, // 0
    [NAND]      = 0b101000, // (top & next)'
//  [NOT_NEXT]  = 0b101010, // (next)'
    [XOR]       = 0b101100, // top ^ next
    [XNOR]      = 0b110010, // (top ^ next)'
    [NEXT]      = 0b110100, // next
    [AND]       = 0b110110, // top & next
    [OR]        = 0b111100, // top | next
    [TOP]       = 0b111110  // top
};

// ********** Define the microinstruction encoding
enum WORD_OFFSETS {
    nx_ustate,                  // 4 bits
    alu_op = nx_ustate + 4,     // 6 bits
    alu_en = alu_op + 6,        // 1 bit
    top_en,                     // 1 bit
    count_up,                   // 1 bit
    count_sel,                  // 2 bits
    load_sel = count_sel + 2,   // 2 bits
    addr_sel = load_sel + 2,    // 2 bits
    iack = addr_sel + 2,        // 1 bit
    write,                      // 1 bit
    read                        // 1 bit
};                       // total 22 bits

// These will get OR'd together to create a microinstruction
const unsigned int  READ        = 1 << read,
                    WRITE       = 1 << write,
                    IACK        = 1 << iack,
                    ADDR_TOP    = 0 << addr_sel,
                    ADDR_DSP    = 1 << addr_sel,
                    ADDR_RSP    = 2 << addr_sel,
                    ADDR_PC     = 3 << addr_sel,
                    LOAD_TOP    = 0 << load_sel,
                    LOAD_NEXT   = 1 << load_sel,
                    LOAD_IR     = 2 << load_sel,
                    LOAD_PC     = 3 << load_sel,
                    COUNT_DSP   = 1 << count_sel,
                    COUNT_RSP   = 2 << count_sel,
                    COUNT_PC    = 3 << count_sel,
                    COUNT_UP    = 1 << count_up,
                    TOP_EN      = 1 << top_en,
                    ALU_EN      = 1 << alu_en;

#define ALU(op)     (ALU_OPCODES[op] << alu_op)
#define GOTO(state) (state << nx_ustate)

#endif //MICROCODE_H