# Usage: make TEST=rtl_pos_test|rtl_neg_test|rtl_corner_test SIM=questa|vcs|xrun
TEST ?= rtl_pos_test
SIM  ?= questa
SRCS  = rtl.sv rtl_if.sv rtl_sva.sv rtl_pkg.sv tb_top.sv

run:
ifeq ($(SIM),questa)
	vlog -sv +incdir+. $(SRCS)
	vsim -c -sv_seed random tb_top +UVM_TESTNAME=$(TEST) -coverage \
	     -do "run -all; coverage report -summary; quit -f"
else ifeq ($(SIM),vcs)
	vcs -full64 -sverilog -ntb_opts uvm-1.2 -cm assert+cond+fsm+tgl -timescale=1ns/1ps \
	    +incdir+. $(SRCS) -o simv && ./simv +UVM_TESTNAME=$(TEST) -cm assert
else ifeq ($(SIM),xrun)
	xrun -sv -uvm -access +rwc +incdir+. $(SRCS) +UVM_TESTNAME=$(TEST)
endif

all:
	for t in rtl_pos_test rtl_neg_test rtl_corner_test; do $(MAKE) run TEST=$$t SIM=$(SIM); done
