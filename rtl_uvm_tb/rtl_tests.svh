// -----------------------------------------------------------------------------
// rtl_tests.svh - Base test + Positive / Negative / Corner tests
// Run with +UVM_TESTNAME=rtl_pos_test | rtl_neg_test | rtl_corner_test
// -----------------------------------------------------------------------------
class rtl_base_test extends uvm_test;
  `uvm_component_utils(rtl_base_test)
  rtl_env        env;
  virtual rtl_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = rtl_env::type_id::create("env", this);
    if (!uvm_config_db#(virtual rtl_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "virtual interface 'vif' not set for test")
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  task run_seq(uvm_phase phase, rtl_base_seq seq);
    phase.raise_objection(this);
    seq.start(env.agt.sqr);
    repeat (5) @(posedge vif.clk);        // drain: let the last responses reach the monitor
    phase.drop_objection(this);
  endtask
endclass

class rtl_pos_test extends rtl_base_test;
  `uvm_component_utils(rtl_pos_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    rtl_pos_seq seq = rtl_pos_seq::type_id::create("pos_seq");
    run_seq(phase, seq);
  endtask
endclass

class rtl_neg_test extends rtl_base_test;
  `uvm_component_utils(rtl_neg_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    rtl_neg_seq seq = rtl_neg_seq::type_id::create("neg_seq");
    run_seq(phase, seq);
  endtask
endclass

class rtl_corner_test extends rtl_base_test;
  `uvm_component_utils(rtl_corner_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    rtl_corner_seq seq = rtl_corner_seq::type_id::create("corner_seq");
    run_seq(phase, seq);
  endtask
endclass
