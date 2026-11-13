// -----------------------------------------------------------------------------
// rtl_scoreboard.svh - Cycle-accurate checker against rtl_predict() (see rtl_pkg)
// -----------------------------------------------------------------------------
class rtl_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(rtl_scoreboard)
  uvm_analysis_imp #(rtl_item, rtl_scoreboard) imp;

  int unsigned n_checked, n_fail;
  int unsigned n_ontime_in, n_late_in, n_leave, n_early_out, n_ontime_out;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction

  function bit chk(string sig, logic got, bit exp_v, rtl_item t);
    if (got !== exp_v) begin
      `uvm_error("SB_MISMATCH", $sformatf("%s: got=%b expected=%b | %s",
                                          sig, got, exp_v, t.convert2string()))
      return 0;
    end
    return 1;
  endfunction

  function void write(rtl_item t);
    rtl_exp_s e;
    bit ok;
    e  = rtl_predict(t.hr_in1, t.hr_in2, t.min_in, t.hr_out);
    ok = 1;
    n_checked++;
    ok &= chk("login",        t.login,        e.login,        t);
    ok &= chk("late_login",   t.late_login,   e.late_login,   t);
    ok &= chk("intime_login", t.intime_login, e.intime_login, t);
    ok &= chk("early_logout", t.early_logout, e.early_logout, t);
    ok &= chk("on_leave",     t.on_leave,     e.on_leave,     t);
    ok &= chk("ontime_out",   t.ontime_out,   e.ontime_out,   t);
    if (!ok) n_fail++;
    // statistics of what was actually exercised (from the expected values)
    if (e.intime_login) n_ontime_in++;
    if (e.late_login)   n_late_in++;
    if (e.on_leave)     n_leave++;
    if (e.early_logout) n_early_out++;
    if (e.ontime_out)   n_ontime_out++;
  endfunction

  function void check_phase(uvm_phase phase);
    if (n_checked == 0)
      `uvm_error("SB_EMPTY", "Scoreboard checked zero transactions")
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SB_SUMMARY", $sformatf(
      "checked=%0d failed=%0d | on-time in=%0d late in=%0d on_leave=%0d | early out=%0d on-time out=%0d",
      n_checked, n_fail, n_ontime_in, n_late_in, n_leave, n_early_out, n_ontime_out), UVM_LOW)
    if (n_fail == 0 && n_checked > 0) `uvm_info("SB_RESULT", "** TEST PASSED **", UVM_NONE)
    else                              `uvm_info("SB_RESULT", "** TEST FAILED **", UVM_NONE)
  endfunction
endclass
