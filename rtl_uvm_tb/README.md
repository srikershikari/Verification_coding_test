# UVM testbench - employee login/logout tracker (`rtl`)

## Architecture
```
 rtl_test (pos | neg | corner)
   └─ rtl_env
       ├─ rtl_agent
       │    ├─ rtl_sequencer ──► rtl_driver ──► [rtl_if / drv_cb] ──► DUT (rtl) ◄── rtl_sva (bound)
       │    └─ rtl_monitor  ◄── [rtl_if / mon_cb] ◄──────────────────┘
       │            │ analysis_port (one rtl_item per cycle: inputs(N) + outputs(N+1))
       ├─ rtl_scoreboard  (rtl_predict() reference model, 6 flags checked per cycle)
       └─ rtl_coverage    (covergroup: input bins, result bins, transitions, crosses)
```

## Run
`make TEST=rtl_pos_test SIM=questa` (or `vcs`, `xrun`; `make all` runs the three tests).
Needs a UVM-capable simulator. Not Verilator (no usable UVM support).

## Assumptions (the spec leaves these open - all live in `rtl_predict()` in rtl_pkg.sv + rtl.sv)
1. No reset port: every output is recomputed from the inputs on each posedge; `late_login` is combinational.
2. Login valid = (hr_in1==9 or hr_in2==10) and min_in<=59. min_in 60..63 is treated as invalid -> on_leave.
3. Schedule for logout: hr_in1==9 -> 9-6 (priority if both match), else 10-7.
4. hr is 4 bits, so hr_out is a 12-hour PM-style value: on-time if hr_out>=6 (9-6) / >=7 (10-7). min_out is ignored.
5. No valid login -> on_leave=1, login=0, both logout flags 0.
If your RTL differs on any of these, change `rtl_predict()` and the matching lines in rtl_sva.sv.
