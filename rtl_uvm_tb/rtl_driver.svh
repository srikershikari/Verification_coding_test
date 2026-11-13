// -----------------------------------------------------------------------------
// rtl_driver.svh - Drives one item per clock cycle through the driver clocking
// block. Inputs change 1 ns after the edge; the DUT captures them on the next.
// -----------------------------------------------------------------------------
class rtl_driver extends uvm_driver #(rtl_item);
  `uvm_component_utils(rtl_driver)
  virtual rtl_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual rtl_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"virtual interface 'vif' not set for ", get_full_name()})
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_item(rtl_item t);
    @(vif.drv_cb);                       // one item per cycle
    vif.drv_cb.hr_in1  <= t.hr_in1;
    vif.drv_cb.hr_in2  <= t.hr_in2;
    vif.drv_cb.min_in  <= t.min_in;
    vif.drv_cb.hr_out  <= t.hr_out;
    vif.drv_cb.min_out <= t.min_out;
    `uvm_info("DRV", t.convert2string(), UVM_HIGH)
  endtask
endclass
