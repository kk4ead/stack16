VERILOG=iverilog

all: alu_test

tests: alu_test

run_tests: run_alu_test

alu_test: 74181b.v alu.v alu_testbench.v
	$(VERILOG) alu_testbench.v alu.v 74181b.v -o alu_test

run_alu_test: alu_test
	./alu_test

clean:
	rm ./alu_test

