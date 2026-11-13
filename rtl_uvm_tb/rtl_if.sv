// -----------------------------------------------------------------------------
// rtl_if.sv - DUT interface with driver/monitor clocking blocks
// -----------------------------------------------------------------------------
interface rtl_if (input logic clk);
  logic [3:0] hr_in1, hr_in2, hr_out;
  logic [5:0] min_in, min_out;
  logic       login, late_login, intime_login, early_logout, on_leave, ontime_out;

  // inputs are quiet (zero) until the driver takes over
  initial begin
    hr_in1 = '0; hr_in2 = '0; hr_out = '0; min_in = '0; min_out = '0;
  end

  // Driver: drive 1 ns after the edge, DUT captures on the next edge
  clocking drv_cb @(posedge clk);
    default input #1step output #1;
    output hr_in1, hr_in2, min_in, hr_out, min_out;
  endclocking

  // Monitor: everything sampled in the preponed region of the edge
  clocking mon_cb @(posedge clk);
    default input #1step;
    input hr_in1, hr_in2, min_in, hr_out, min_out;
    input login, late_login, intime_login, early_logout, on_leave, ontime_out;
  endclocking

  modport DRV (clocking drv_cb, input clk);
  modport MON (clocking mon_cb, input clk);
endinterface
