// -----------------------------------------------------------------------------
// rtl_sva.sv - Assertions, bound into the DUT (no DUT edits needed).
// Registered outputs reflect the inputs of the PREVIOUS edge, hence |=> / $past.
// -----------------------------------------------------------------------------
module rtl_sva (
  input logic       clk,
  input logic [3:0] hr_in1, hr_in2, hr_out,
  input logic [5:0] min_in, min_out,
  input logic       login, late_login, intime_login, early_logout, on_leave, ontime_out
);
  logic started;
  initial started = 1'b0;
  always @(posedge clk) started <= 1'b1;

  wire sch1     = (hr_in1 == 4'd9);
  wire sch2     = (hr_in2 == 4'd10);
  wire min_ok   = (min_in <= 6'd59);
  wire login_ok = (sch1 || sch2) && min_ok;

  default clocking cb @(posedge clk); endclocking
  default disable iff (!started);

  // ---- sanity ---------------------------------------------------------------
  a_no_x : assert property (!$isunknown({login, late_login, intime_login,
                                         early_logout, on_leave, ontime_out}))
           else $error("SVA: X/Z on an output");

  // ---- combinational late_login ----------------------------------------------
  a_late_comb : assert property (late_login == (login_ok && (min_in != 6'd0)))
           else $error("SVA: late_login does not match combinational definition");

  // ---- login family ----------------------------------------------------------
  a_login_xor_leave : assert property (login != on_leave)
           else $error("SVA: login and on_leave must be mutually exclusive");

  a_ontime_resp : assert property ((login_ok && min_in == 6'd0) |=>
                                   (login && intime_login && !on_leave))
           else $error("SVA: on-time login not flagged");

  a_late_resp : assert property (late_login |=>
                                 (login && !intime_login && !on_leave))
           else $error("SVA: late login not flagged");

  a_leave_resp : assert property (!login_ok |=>
                                  (on_leave && !login && !intime_login))
           else $error("SVA: absent employee not marked on_leave");

  a_intime_implies_login : assert property (intime_login |-> login)
           else $error("SVA: intime_login without login");

  a_login_class : assert property (login |-> (intime_login ^ $past(late_login)))
           else $error("SVA: login must be exactly one of on-time / late");

  // ---- logout family ---------------------------------------------------------
  a_logout_excl : assert property (!(early_logout && ontime_out))
           else $error("SVA: early_logout and ontime_out both set");

  a_login_has_logout_flag : assert property (login |-> (early_logout ^ ontime_out))
           else $error("SVA: logged-in employee must have exactly one logout flag");

  a_leave_no_logout : assert property (!login_ok |=> (!early_logout && !ontime_out))
           else $error("SVA: logout flag raised while on leave");

  // 9-6 schedule (hr_in1 has priority when both hours match)
  a_s1_logout : assert property ((login_ok && sch1) |=>
        (($past(hr_out) >= 4'd6) ? (ontime_out && !early_logout)
                                 : (early_logout && !ontime_out)))
           else $error("SVA: 9-6 logout classification wrong");

  // 10-7 schedule
  a_s2_logout : assert property ((login_ok && !sch1) |=>
        (($past(hr_out) >= 4'd7) ? (ontime_out && !early_logout)
                                 : (early_logout && !ontime_out)))
           else $error("SVA: 10-7 logout classification wrong");

  // ---- cover properties ------------------------------------------------------
  c_ontime_login : cover property (login_ok && min_in == 6'd0);
  c_late_login   : cover property (late_login);
  c_on_leave     : cover property (!login_ok);
  c_early_out    : cover property (login && early_logout);
  c_ontime_out   : cover property (login && ontime_out);
  c_both_sched   : cover property (sch1 && sch2 && min_ok);
  c_bad_minute   : cover property ((sch1 || sch2) && !min_ok);
  c_s1_edge_out  : cover property (login_ok && sch1  && hr_out == 4'd6);
  c_s2_edge_out  : cover property (login_ok && !sch1 && hr_out == 4'd7);
endmodule

bind rtl rtl_sva u_rtl_sva (.*);
