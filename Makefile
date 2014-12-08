VERILOG=iverilog
VFLAGS=-Wall -Winfloop
CFLAGS=-Wall -Wextra -Wpedantic -Werror -std=c99

top: Datapath.v ControlFSM.v BitsliceALU.v 74181b.v
	$(VERILOG) $(VFLAGS) -otop Datapath.v ControlFSM.v BitsliceALU.v 74181b.v

run: run_alu_test

deps: 74181b.v

74181b.v:
	curl -O http://web.eecs.umich.edu/~jhayes/iscas.restore/74181b.v

alu_test: 74181b.v BitsliceALU.v alu_test.v
	$(VERILOG) $(VFLAGS) -oalu_test alu_testbench.v BitsliceALU.v 74181b.v

run_alu_test: alu_test
	./alu_test

clean:
	rm -f ./alu_test
	rm -f ./top

distclean: clean
	rm -f ./74181b.v