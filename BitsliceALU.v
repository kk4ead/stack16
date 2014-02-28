/* a 16-bit ALU built from four 74181's
   Uses behavioral 74181 model from M. Hansen, H. Yalcin, and J. P. Hayes,
   "Unveiling the ISCAS-85 Benchmarks: A Case Study in Reverse Engineering,"
   IEEE Design and Test, vol. 16, no. 3, pp. 72-80, July-Sept. 1999.
   http://web.eecs.umich.edu/~jhayes/iscas.restore/
 */
   

/* Operations: 
    00 = A                      A plus 1
    03 = minus 1                0
    06 =                        A minus B
    09 = A plus B
    0c = A plus A
    0f = A minus 1              A
    10 = A'
    11 = (A or B)'
    14 = (A and B)'
    15 = B'
    16 = A xor B
    19 = (A xor B)'
    1a = B
    1b = A and B
    1c = 1
    1e = A or B
*/

module BitsliceALU (A, B, Op, Swap, Q, Carry, Zero, Minus1);
    input  [15:0] A, B;
    input  [4:0] Op;
    input  Swap;
    output [15:0] Q;
    output Carry, Zero, Minus1;
    
    wire C3, C7, C11, C15;
    wire Z3, Z7, Z11, Z15;
    wire [3:0] X, Y;
    wire [15:0] result;
    
    Circuit74181b slice3
        (Op[3:0], A[3:0], B[3:0], Op[4], 1'b1, result[3:0], X[0], Y[0], C3, Z3);
    
    Circuit74181b slice7
        (Op[3:0], A[7:4], B[7:4], Op[4], C3, result[7:4], X[1], Y[1], C7, Z7);
    
    Circuit74181b slice11
        (Op[3:0], A[11:8], B[11:8], Op[4], C7, result[11:8], X[2], Y[2], C11, Z11);
    
    Circuit74181b slice15
        (Op[3:0], A[15:12], B[15:12], Op[4], C11, result[15:12], X[3],Y[3],C15,Z15);

    // infer single inverter
    assign Carry = ~C15;
    
    // infer 16-input AND
    assign Zero = (Q == 16'h0000);

    // infer 4-input AND
    assign Minus1 = Z3 && Z7 && Z11 && Z15;

    // infer 16-bit 2-way mux
    assign Q = Swap ? {result[7:0], result[15:8]} : result;
            
endmodule