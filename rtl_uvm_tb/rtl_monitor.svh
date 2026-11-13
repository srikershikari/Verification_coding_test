// -----------------------------------------------------------------------------
// rtl_monitor.svh - Passive monitor.
// Registered outputs sampled at edge N+1 are the response to the inputs sampled
// at edge N, so the monitor pairs "previous inputs" with "current outputs".
// late_login is combinational and is captured together with its own inputs.
// Every clock cycle produces one transaction.
// -----------------------------------------------------------------------------
class rtl_monitor extends uvm_monitor;
  `uvm_component_utils(rtl_monitor)
  virtual rtl_if vif;
  uvm_analysis_port #(rtl_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual rtl_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface 'vif' not set for ", get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);
    rtl_item prev, cur;
    forever begin
      @(vif.mon_cb);
      cur = rtl_item::type_id::create("mon_item");
      cur.hr_in1     = vif.mon_cb.hr_in1;
      cur.hr_in2     = vif.mon_cb.hr_in2;
      cur.min_in     = vif.mon_cb.min_in;
      cur.hr_out     = vif.mon_cb.hr_out;
      cur.min_out    = vif.mon_cb.min_out;
      cur.late_login = vif.mon_cb.late_login;   // combinational: same-cycle
      if (prev != null) begin                    // registered: previous-cycle result
        prev.login        = vif.mon_cb.login;
        prev.intime_login = vif.mon_cb.intime_login;
        prev.early_logout = vif.mon_cb.early_logout;
        prev.on_leave     = vif.mon_cb.on_leave;
        prev.ontime_out   = vif.mon_cb.ontime_out;
        `uvm_info("MON", prev.convert2string(), UVM_HIGH)
        ap.write(prev);
      end
      prev = cur;
    end
  endtask
endclass
