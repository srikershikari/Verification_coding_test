// -----------------------------------------------------------------------------
// rtl_coverage.svh - Functional coverage, sampled from monitored transactions.
// Result-side coverpoints use the OBSERVED DUT flags, input-side use the stimulus.
// -----------------------------------------------------------------------------
class rtl_coverage extends uvm_subscriber #(rtl_item);

  `uvm_component_utils(rtl_coverage)

  bit [3:0]    c_hr_in1, c_hr_in2, c_hr_out;
  bit [5:0]    c_min_in, c_min_out;
  sched_e      c_sched;
  login_res_e  c_login;
  logout_res_e c_logout;

  covergroup cg;
    option.per_instance = 1;
    option.name = "rtl_func_cov";

    // ---- input-side ----------------------------------------------------------
    cp_hr_in1 : coverpoint c_hr_in1 {
      bins sched1_hr = {SCHED1_IN_HR};
      bins sched2_hr = {SCHED2_IN_HR};      // 10 on the 9-6 port
      bins before_9  = {[0:8]};
      bins after_10  = {[11:15]};
    }
    cp_hr_in2 : coverpoint c_hr_in2 {
      bins sched2_hr = {SCHED2_IN_HR};
      bins sched1_hr = {SCHED1_IN_HR};      // 9 on the 10-7 port
      bins below_9   = {[0:8]};
      bins above_10  = {[11:15]};
    }
    cp_min_in : coverpoint c_min_in {
      bins on_time    = {0};
      bins late_first = {1};
      bins late_mid   = {[2:58]};
      bins late_last  = {59};
      bins illegal    = {[60:63]};
    }
    cp_hr_out : coverpoint c_hr_out {
      bins zero      = {0};
      bins early_lo  = {[1:4]};
      bins h5        = {5};
      bins h6        = {6};
      bins h7        = {7};
      bins h8_12     = {[8:12]};
      bins h13_15    = {[13:15]};
    }
    cp_min_out : coverpoint c_min_out {
      bins zero    = {0};
      bins mid     = {[1:58]};
      bins last    = {59};
      bins illegal = {[60:63]};
    }
    cp_sched : coverpoint c_sched;

    // ---- result-side (observed flags) ------------------------------------------
    cp_login  : coverpoint c_login;
    cp_logout : coverpoint c_logout;
    cp_login_trans : coverpoint c_login {
      bins t[] = (LG_ONTIME, LG_LATE, LG_LEAVE => LG_ONTIME, LG_LATE, LG_LEAVE);
    }
    cp_logout_trans : coverpoint c_logout {
      bins t[] = (LO_ONTIME, LO_EARLY, LO_NONE => LO_ONTIME, LO_EARLY, LO_NONE);
    }

    // ---- crosses ---------------------------------------------------------------
    x_sched_login : cross cp_sched, cp_login {
      ignore_bins no_sched_no_login = binsof(cp_sched) intersect {SCH_NONE} &&
                                      binsof(cp_login) intersect {LG_ONTIME, LG_LATE};
    }
    x_sched_logout : cross cp_sched, cp_logout {
      ignore_bins no_sched_no_logout = binsof(cp_sched) intersect {SCH_NONE} &&
                                       binsof(cp_logout) intersect {LO_ONTIME, LO_EARLY};
    }
    x_hrout_sched : cross cp_hr_out, cp_sched {
      ignore_bins none = binsof(cp_sched) intersect {SCH_NONE};
    }
    x_minin_sched : cross cp_min_in, cp_sched;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  function void write(rtl_item t);
    c_hr_in1  = t.hr_in1;  c_hr_in2 = t.hr_in2;  c_hr_out = t.hr_out;
    c_min_in  = t.min_in;  c_min_out = t.min_out;
    c_sched   = t.sched();
    c_login   = (t.on_leave === 1'b1)     ? LG_LEAVE :
                (t.intime_login === 1'b1) ? LG_ONTIME : LG_LATE;
    c_logout  = (t.ontime_out === 1'b1)   ? LO_ONTIME :
                (t.early_logout === 1'b1) ? LO_EARLY  : LO_NONE;
    cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("Functional coverage = %0.2f%%", cg.get_inst_coverage()), UVM_NONE)
  endfunction
endclass
