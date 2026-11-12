/********************************************************************************************
Filename    :	   interface.sv   

Description :      interface & assertions

Author Name :      Sriker

Version     :      1.1
*********************************************************************************************/
interface rtl_if ( input bit clk );
    
        logic [ 3 : 0 ] hr_in1, hr_in2, hr_out;
        logic [ 5 : 0 ] min_in, min_out;
        logic       login, late_login, intime_login, early_logout, on_leave, ontime_out;
      
        clocking drv_cb @( posedge clk );
        
                default input #1 output #1;
        
                output hr_in1, hr_in2, min_in, hr_out, min_out;
        
        endclocking

        
        clocking mon_cb @( posedge clk );
        
                default input #1 output #1;
                
                input hr_in1, hr_in2, min_in, hr_out, min_out;
                
                input login, late_login, intime_login, early_logout, on_leave, ontime_out;
                
        endclocking
        

        modport DRV ( clocking drv_cb );
        
        modport MON ( clocking mon_cb );
        
        
        logic started, started_d;
        initial begin started = 1'b0; started_d = 1'b0; end
        always @(posedge clk) begin
        started   <= 1'b1;
        started_d <= started;
        end

        default disable iff (!started_d);     // or put it in each assertion
        
        //Assertions
        //wire sch1     = (hr_in1 == 4'd9);
        
        wire sch1     = (hr_in1 <= 4'd9);
        
        //wire sch2     = (hr_in2 == 4'd10);
        
        wire sch2     = (hr_in2 <= 4'd10);
        
        wire min_ok   = (min_in <= 6'd59);
        
        wire login_ok = (sch1 || sch2) && min_ok;
        
        //$error("SVA: late_login does not match combinational definition");
        property P1;
                
                @( posedge clk ) late_login == ( login_ok && ( min_in != 6'd0 ) );
                
        endproperty
        
        late_comb : assert property( P1 )
                else $error("SVA: late_login does not match combinational definition \n");
        
        login_xor_leave : assert property ( @( posedge clk ) login != on_leave )
                else $error("SVA: login and on_leave must be different \n");
        
        intime_implies_login : assert property ( @( posedge clk ) intime_login |-> login)
                else $error("SVA: when intime_login is 1, login must also be 1 \n");
       
        logout : assert property ( @( posedge clk ) !( early_logout && ontime_out ) )
                else $error("SVA: early_logout and ontime_out cannot have same value \n");
        
        no_logout : assert property ( @( posedge clk ) !login_ok |=> ( !early_logout && !ontime_out ) )
                else $error("SVA: logout flag raised without a valid login \n");
  
endinterface : rtl_if







/*
Why drv_cb has both and mon_cb has one

--> In drv_cb, the driver drives the five stimulus signals, so they are declared output and need an output skew. The output #1 makes the pins change 1 ns after the edge, which avoids a race with the DUT sampling on that edge.

What #1step buys you on the monitor side

-->It samples the values from just before the edge. That avoids a race with the DUT’s own non-blocking updates at that same edge, so the monitor sees clean, stable values.

-->In mon_cb, every signal is declared input. The block has no output signals, so output #1 would apply to nothing. Some tools accept it silently, others warn about it.

-->This sampling is the reason for the one-cycle shift between inputs and registered outputs that we discussed earlier.


What each skew does

-->input #1step sets when the clocking block samples signals declared "input". #1step means the value just "before" the clock edge (the preponed value).

-->output #1 sets when the block drives signals declared output. The drive happens 1 ns "after" the edge.


No, it won’t change anything in your testbench. 
-->The output #1 only applies to signals declared output inside that clocking block. 
-->mon_cb declares only input signals, so the output skew has nothing to apply to.

-->DUT outputs aren’t affected: in a clocking block, input and output are from the testbench’s side. 
-->"input" means the testbench samples the signal,
-->and "output" means the testbench drives it. 
-->The DUT’s outputs (login, on_leave and the rest) are input in mon_cb, so the monitor samples them with the #1step skew as before.

-->Sampling is unchanged: the input #1step part still controls every sample the monitor takes.

-->Possible warning: some tools accept the unused output skew silently, while others may print a warning. VCS normally accepts it.

-->I’d still leave output #1 out of mon_cb. 
-->It does nothing, and it hints that the monitor can drive, which it must not. If someone later adds an output signal to mon_cb by mistake, the skew would make that mistake compile quietly.

*/






























