// -----------------------------------------------------------------------------
// rtl.sv - REFERENCE implementation of the employee login/logout tracker.
// Written from the spec so the testbench has something to run against.
// Replace with your own RTL; the testbench only depends on the port list.
//
// Interpretation (see README "Assumptions"):
//   * Every cycle all inputs are sampled together; outputs are recomputed.
//   * Login valid  : (hr_in1==9 || hr_in2==10) && min_in<=59
//   * Schedule     : hr_in1==9 -> 9-6 (priority), else 10-7
//   * Logout       : hr_out >= 6 (9-6) / >= 7 (10-7) -> ontime_out, else early_logout
//   * No valid login -> on_leave, and neither logout flag is raised
//   * late_login is combinational, everything else registered
// -----------------------------------------------------------------------------
module rtl ( 
  input            clk,
  input      [3:0] hr_in1,
  input      [3:0] hr_in2,
  input      [5:0] min_in,
  output reg       login,
  input      [3:0] hr_out,
  input      [5:0] min_out,   // not used by the reference behaviour
  output           late_login,
  output reg       intime_login,
  output reg       early_logout,
  output reg       on_leave,
  output reg       ontime_out
);

  /* verilator lint_off UNUSEDSIGNAL */
  wire [5:0] min_out_unused = min_out;
  /* verilator lint_on UNUSEDSIGNAL */

  wire       sch1     = (hr_in1 == 4'd9);
  wire       sch2     = (hr_in2 == 4'd10);
  wire       min_ok   = (min_in <= 6'd59);
  wire       login_ok = min_ok & (sch1 | sch2);
  wire [3:0] out_thr  = sch1 ? 4'd6 : 4'd7;

  assign late_login = login_ok & (min_in != 6'd0);

  always @(posedge clk) login        <= login_ok;
  always @(posedge clk) intime_login <= login_ok & (min_in == 6'd0);
  always @(posedge clk) on_leave     <= ~login_ok;
  always @(posedge clk) ontime_out   <= login_ok & (hr_out >= out_thr);
  always @(posedge clk) early_logout <= login_ok & (hr_out <  out_thr);
endmodule
