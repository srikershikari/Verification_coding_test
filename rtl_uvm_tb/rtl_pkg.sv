// -----------------------------------------------------------------------------
// rtl_pkg.sv - UVM package: constants, reference model, and component includes
// -----------------------------------------------------------------------------
package rtl_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---- Schedule constants (edit here if the spec changes) --------------------
  localparam bit [3:0] SCHED1_IN_HR  = 4'd9;   // 9-6 schedule  (hr_in1)
  localparam bit [3:0] SCHED1_OUT_HR = 4'd6;
  localparam bit [3:0] SCHED2_IN_HR  = 4'd10;  // 10-7 schedule (hr_in2)
  localparam bit [3:0] SCHED2_OUT_HR = 4'd7;
  localparam bit [5:0] MAX_MIN       = 6'd59;

  typedef enum {SCH_NONE, SCH_1, SCH_2, SCH_BOTH} sched_e;
  typedef enum {LG_ONTIME, LG_LATE, LG_LEAVE}     login_res_e;
  typedef enum {LO_ONTIME, LO_EARLY, LO_NONE}     logout_res_e;

  typedef struct packed {
    bit login;
    bit late_login;
    bit intime_login;
    bit early_logout;
    bit on_leave;
    bit ontime_out;
  } rtl_exp_s;

  // ---- Reference model: ONE place that encodes the spec ----------------------
  function automatic rtl_exp_s rtl_predict(bit [3:0] hr_in1, bit [3:0] hr_in2,
                                           bit [5:0] min_in, bit [3:0] hr_out);
    rtl_exp_s e;
    bit       sch1, sch2, min_ok, login_ok;
    bit [3:0] thr;
    sch1     = (hr_in1 == SCHED1_IN_HR);
    sch2     = (hr_in2 == SCHED2_IN_HR);
    min_ok   = (min_in <= MAX_MIN);
    login_ok = min_ok && (sch1 || sch2);
    thr      = sch1 ? SCHED1_OUT_HR : SCHED2_OUT_HR;   // 9-6 has priority
    e.login        = login_ok;
    e.intime_login = login_ok && (min_in == 0);
    e.late_login   = login_ok && (min_in != 0);
    e.on_leave     = !login_ok;
    e.ontime_out   = login_ok && (hr_out >= thr);
    e.early_logout = login_ok && (hr_out <  thr);
    return e;
  endfunction

  `include "rtl_item.svh"
  `include "rtl_sequences.svh"
  `include "rtl_driver.svh"
  `include "rtl_monitor.svh"
  `include "rtl_scoreboard.svh"
  `include "rtl_coverage.svh"
  `include "rtl_env.svh"
  `include "rtl_tests.svh"
endpackage











