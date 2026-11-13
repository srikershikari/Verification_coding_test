// -----------------------------------------------------------------------------
// rtl_item.svh - Sequence item. One item == one clock cycle of input stimulus.
// Stimulus fields are rand; observed fields are filled in by the monitor.
// -----------------------------------------------------------------------------
class rtl_item extends uvm_sequence_item;
  `uvm_object_utils(rtl_item)

  // stimulus
  rand bit [3:0] hr_in1, hr_in2, hr_out;
  rand bit [5:0] min_in, min_out;

  // observed (logic so X/Z survive to the scoreboard)
  logic login, late_login, intime_login, early_logout, on_leave, ontime_out;

  // soft: directed/negative sequences override with inline constraints
  constraint c_legal_min { soft min_in <= MAX_MIN; soft min_out <= MAX_MIN; }

  function new(string name = "rtl_item");
    super.new(name);
  endfunction

  function sched_e sched();
    bit s1 = (hr_in1 == SCHED1_IN_HR);
    bit s2 = (hr_in2 == SCHED2_IN_HR);
    if (s1 && s2) return SCH_BOTH;
    if (s1)       return SCH_1;
    if (s2)       return SCH_2;
    return SCH_NONE;
  endfunction

  virtual function void do_copy(uvm_object rhs);
    rtl_item r;
    super.do_copy(rhs);
    if (!$cast(r, rhs)) `uvm_fatal("CAST", "rtl_item do_copy cast failed")
    hr_in1 = r.hr_in1; hr_in2 = r.hr_in2; hr_out = r.hr_out;
    min_in = r.min_in; min_out = r.min_out;
    login = r.login; late_login = r.late_login; intime_login = r.intime_login;
    early_logout = r.early_logout; on_leave = r.on_leave; ontime_out = r.ontime_out;
  endfunction

  virtual function string convert2string();
    return $sformatf("in1=%0d in2=%0d min_in=%0d | out=%0d:%0d || login=%b late=%b intime=%b early_out=%b leave=%b ontime_out=%b",
                     hr_in1, hr_in2, min_in, hr_out, min_out,
                     login, late_login, intime_login, early_logout, on_leave, ontime_out);
  endfunction
endclass
