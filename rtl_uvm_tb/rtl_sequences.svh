// -----------------------------------------------------------------------------
// rtl_sequences.svh - Base sequence + Positive / Negative / Corner sequences
// -----------------------------------------------------------------------------
class rtl_base_seq extends uvm_sequence #(rtl_item);
  `uvm_object_utils(rtl_base_seq)
  int unsigned n_rand = 50;

  function new(string name = "rtl_base_seq");
    super.new(name);
  endfunction

  // Directed single-cycle transaction. Argument names differ from item fields
  // on purpose so the inline constraint resolves unambiguously.
  task send(bit [3:0] a_hr_in1, bit [3:0] a_hr_in2, bit [5:0] a_min_in,
            bit [3:0] a_hr_out, bit [5:0] a_min_out);
    rtl_item it = rtl_item::type_id::create("it");
    start_item(it);
    if (!it.randomize() with { hr_in1 == a_hr_in1; hr_in2 == a_hr_in2;
                               min_in == a_min_in; hr_out == a_hr_out;
                               min_out == a_min_out; })
      `uvm_fatal("RAND", "directed randomize failed")
    finish_item(it);
  endtask
endclass

// =============================================================================
// POSITIVE: valid logins on either schedule, on-time and late, every logout kind
// =============================================================================
class rtl_pos_seq extends rtl_base_seq;
  `uvm_object_utils(rtl_pos_seq)
  function new(string name = "rtl_pos_seq"); super.new(name); endfunction

  task body();
    `uvm_info(get_type_name(), "Positive sequence start", UVM_LOW)
    // ---- 9-6 schedule via hr_in1 (hr_in2 parked at 0) ------------------------
    send(9, 0,  0, 6,  0);   // on-time in, on-time out (exactly 6)
    send(9, 0,  0, 8, 30);   // on-time in, stays late
    send(9, 0,  0, 4,  0);   // on-time in, early out
    send(9, 0, 30, 6, 30);   // late in,    on-time out
    send(9, 0, 15, 3, 45);   // late in,    early out
    // ---- 10-7 schedule via hr_in2 (hr_in1 parked at 0) -----------------------
    send(0, 10,  0, 7,  0);  // on-time in, on-time out (exactly 7)
    send(0, 10,  0, 9, 15);  // on-time in, stays late
    send(0, 10,  0, 5,  0);  // on-time in, early out
    send(0, 10, 20, 7, 30);  // late in,    on-time out
    send(0, 10, 45, 6, 59);  // late in,    early out (6 is early for 10-7)

    // ---- constrained random: exactly one valid schedule, legal minutes -------
    repeat (n_rand) begin
      rtl_item it = rtl_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with {
            (hr_in1 == SCHED1_IN_HR) != (hr_in2 == SCHED2_IN_HR);
            min_in  dist {0 := 30, [1:59] :/ 70};
            hr_out  inside {[1:12]};
          })
        `uvm_fatal("RAND", "positive randomize failed")
      finish_item(it);
    end
    `uvm_info(get_type_name(), "Positive sequence done", UVM_LOW)
  endtask
endclass

// =============================================================================
// NEGATIVE: employee never logs in within the hour / illegal minute field.
// Expected: on_leave=1, login=0, no logout flag.
// =============================================================================
class rtl_neg_seq extends rtl_base_seq;
  `uvm_object_utils(rtl_neg_seq)
  function new(string name = "rtl_neg_seq"); super.new(name); endfunction

  task body();
    `uvm_info(get_type_name(), "Negative sequence start", UVM_LOW)
    send( 8,  9, 0, 6, 0);   // early: before both schedules
    send(11, 11, 0, 7, 0);   // late: after both schedules
    send(10,  9, 0, 6, 0);   // hours present but on the WRONG ports (swapped)
    send( 0,  0, 0, 6, 0);   // nothing valid
    send(12,  5, 30, 8, 0);  // arbitrary non-matching hours, late minute
    send(15, 15, 59, 15, 59);
    // illegal minute field with a matching hour -> not a valid login
    send(9,  0, 60, 6, 0);
    send(0, 10, 61, 7, 0);
    send(9, 10, 63, 6, 0);

    // random: guaranteed non-matching hours, any hr_out / min_out
    repeat (n_rand) begin
      rtl_item it = rtl_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with {
            hr_in1 != SCHED1_IN_HR;
            hr_in2 != SCHED2_IN_HR;
            min_in inside {[0:63]};
            min_out inside {[0:63]};
          })
        `uvm_fatal("RAND", "negative randomize (no login) failed")
      finish_item(it);
    end
    // random: matching hour but illegal minute
    repeat (n_rand/2) begin
      rtl_item it = rtl_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with {
            ((hr_in1 == SCHED1_IN_HR) || (hr_in2 == SCHED2_IN_HR));
            min_in inside {[60:63]};
          })
        `uvm_fatal("RAND", "negative randomize (bad minute) failed")
      finish_item(it);
    end
    `uvm_info(get_type_name(), "Negative sequence done", UVM_LOW)
  endtask
endclass

// =============================================================================
// CORNER: boundaries (min 0/1/59/60, hr +/-1, logout threshold-1/=/+1),
// both schedules matching, flag clearing on back-to-back changes, extremes.
// =============================================================================
class rtl_corner_seq extends rtl_base_seq;
  `uvm_object_utils(rtl_corner_seq)
  function new(string name = "rtl_corner_seq"); super.new(name); n_rand = 200; endfunction

  task body();
    `uvm_info(get_type_name(), "Corner sequence start", UVM_LOW)
    // ---- login-minute boundaries ---------------------------------------------
    send(9, 0,  0, 6, 0);  send(9, 0,  1, 6, 0);  send(9, 0, 59, 6, 0);
    send(9, 0, 60, 6, 0);  send(9, 0, 63, 6, 0);
    send(0, 10,  0, 7, 0); send(0, 10,  1, 7, 0); send(0, 10, 59, 7, 0);
    send(0, 10, 60, 7, 0); send(0, 10, 63, 7, 0);
    // ---- login-hour neighbours -----------------------------------------------
    send(8, 0, 0, 6, 0);   send(10, 0, 0, 6, 0);
    send(0, 9, 0, 7, 0);   send(0, 11, 0, 7, 0);
    send(8, 9, 0, 7, 0);                 // 9 on the hr_in2 port: no login
    send(10, 10, 0, 7, 0);               // hr_in1 wrong, hr_in2 right -> 10-7
    send(0, 0, 0, 0, 0);   send(15, 15, 59, 15, 59);
    // ---- logout boundary, 9-6: threshold-1 / = / +1 --------------------------
    send(9, 0, 0, 5, 59);  send(9, 0, 0, 6, 0);   send(9, 0, 0, 7, 0);
    // ---- logout boundary, 10-7 -----------------------------------------------
    send(0, 10, 0, 6, 59); send(0, 10, 0, 7, 0);  send(0, 10, 0, 8, 0);
    // ---- hr_out extremes -----------------------------------------------------
    send(9, 0, 0, 0, 0);   send(9, 0, 0, 15, 0);
    send(0, 10, 0, 0, 0);  send(0, 10, 0, 15, 59);
    // ---- both schedule hours present: 9-6 takes priority ---------------------
    send(9, 10, 0, 6, 0);                // on-time under 9-6 (would be early under 10-7)
    send(9, 10, 0, 5, 59);
    send(9, 10, 1, 6, 0);
    send(9, 10, 60, 6, 0);               // both match but minute illegal -> leave
    // ---- min_out must not influence the result -------------------------------
    send(9, 0, 0, 6, 63);  send(9, 0, 0, 5, 63);
    // ---- back-to-back class changes: flags must clear every cycle ------------
    send(9, 0, 0, 6, 0);   send(9, 0, 30, 6, 0);  send(0, 0, 0, 0, 0);
    send(0, 10, 0, 7, 0);  send(0, 10, 15, 6, 0); send(8, 0, 0, 6, 0);
    send(9, 0, 0, 6, 0);
    // ---- same stimulus held for several cycles -------------------------------
    repeat (3) send(9, 0, 5, 6, 0);

    // ---- biased random over the full input space (incl. illegal minutes) -----
    repeat (n_rand) begin
      rtl_item it = rtl_item::type_id::create("it");
      start_item(it);
      if (!it.randomize() with {
            hr_in1 dist {SCHED1_IN_HR := 40, [0:8] :/ 30, [10:15] :/ 30};
            hr_in2 dist {SCHED2_IN_HR := 40, [0:9] :/ 30, [11:15] :/ 30};
            min_in dist {0 := 15, 1 := 10, [2:58] :/ 40, 59 := 15, [60:63] :/ 20};
            hr_out dist {[0:4] :/ 20, 5 := 15, 6 := 15, 7 := 15, 8 := 10,
                         [9:12] :/ 15, [13:15] :/ 10};
            min_out inside {[0:63]};
          })
        `uvm_fatal("RAND", "corner randomize failed")
      finish_item(it);
    end
    `uvm_info(get_type_name(), "Corner sequence done", UVM_LOW)
  endtask
endclass
