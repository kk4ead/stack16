// test-bench for the ALU

`timescale 1 ns / 100 ps

module alu_testbench ();

reg [15:0] A, B;
reg [4:0] Op;
reg Swap;
wire [15:0] Q;
wire Carry, Zero, Minus1;

BitsliceALU DUT (A, B, Op, Swap, Q, Carry, Zero, Minus1);

task test_vector;
    input [4:0] testOp;
    input testSwap;
    input [15:0] testA, testB;
    input [15:0] expectQ;
    input expectCarry, expectZero, expectMinus1;
    begin
        $display($time, " Op = %h, Swap = %h, A = %h, B = %h", testOp, testSwap, testA, testB);
        A = testA;
        B = testB;
        Op = testOp;
        Swap = testSwap;
        #10 if ( (Q==expectQ) && (Carry==expectCarry) && (Zero==expectZero) && (Minus1==expectMinus1) )
            $display($time, "                                      passed.");
        else
            begin
                if (Q != expectQ)
                    $display($time, "   ... FAILED with Q = %h", Q);
                if (Carry != expectCarry)
                    $display($time, "   ... FAILED with Carry = %h", Carry);
                if (Zero != expectZero)
                    $display($time, "   ... FAILED with Zero = %h", Zero);
                if (Minus1 != expectMinus1)
                    $display($time, "   ... FAILED with Minus1 = %h", Minus1);
            end
    end
endtask

initial
begin
    $display($time, " ##### Testing addition... #####");
    //                 MSSSS          AAAA     BBBB     QQQQ    C    Z   M1
    #10 test_vector(5'b01001,1'b1,16'h4444,16'h2345,16'h8967,1'b0,1'b0,1'b0);
    #10 test_vector(5'b01001,1'b0,16'hf00f,16'hc7c8,16'hb7d7,1'b1,1'b0,1'b0);
    #10 test_vector(5'b01001,1'b1,16'h3cc3,16'h7cc7,16'h8ab9,1'b0,1'b0,1'b0);
    #10 test_vector(5'b01001,1'b0,16'hff00,16'h0100,16'h0000,1'b1,1'b1,1'b0);
    #10 test_vector(5'b01001,1'b1,16'h0000,16'h0000,16'h0000,1'b0,1'b1,1'b0);
    #10 test_vector(5'b01001,1'b0,16'h7777,16'h8888,16'hffff,1'b0,1'b0,1'b1);
end

endmodule