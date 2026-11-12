/********************************************************************************************
Filename    :	   top.sv   

Description :      top module

Author Name :      Sriker

Version     :      1.12
*********************************************************************************************/
module top;

        import uvm_pkg::*;
        
        import test_pkg::*;

        bit clk;
        
        always #5 clk = ~clk;

        rtl_if vif ( clk );

        rtl dut ( 
                .clk          ( clk ),
                
                .hr_in1       ( vif.hr_in1 ),
                
                .hr_in2       ( vif.hr_in2 ),
                
                .min_in       ( vif.min_in ),
                
                .login        ( vif.login ),
                
                .hr_out       ( vif.hr_out ),
                
                .min_out      ( vif.min_out ),
                
                .late_login   ( vif.late_login ),
                
                .intime_login ( vif.intime_login ),
                
                .early_logout ( vif.early_logout ),
                
                .on_leave     ( vif.on_leave ),
                
                .ontime_out   ( vif.ontime_out )
         );

        initial 
        begin
                uvm_config_db#( virtual rtl_if ) :: set( null, "*", "vif", vif );
                
                run_test();
        end


endmodule : top



























