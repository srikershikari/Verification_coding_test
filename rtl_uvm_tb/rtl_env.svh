// -----------------------------------------------------------------------------
// rtl_env.svh - Agent (sequencer + driver + monitor) and environment
// -----------------------------------------------------------------------------
typedef uvm_sequencer #(rtl_item) rtl_sequencer;

class rtl_agent extends uvm_agent;
  `uvm_component_utils(rtl_agent)
  rtl_sequencer sqr;
  rtl_driver    drv;
  rtl_monitor   mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = rtl_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      sqr = rtl_sequencer::type_id::create("sqr", this);
      drv = rtl_driver::type_id::create("drv", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass

class rtl_env extends uvm_env;
  `uvm_component_utils(rtl_env)
  rtl_agent      agt;
  rtl_scoreboard sb;
  rtl_coverage   cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = rtl_agent::type_id::create("agt", this);
    sb  = rtl_scoreboard::type_id::create("sb", this);
    cov = rtl_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agt.mon.ap.connect(sb.imp);
    agt.mon.ap.connect(cov.analysis_export);
  endfunction
endclass
