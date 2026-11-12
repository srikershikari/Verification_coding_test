/********************************************************************************************
Filename    :	   scoreboard.sv   

Description :      scoreboard class

Author Name :      Sriker

Version     :      1.8
*********************************************************************************************/
class scoreboard extends uvm_scoreboard;

        `uvm_component_utils( scoreboard )
        
        uvm_analysis_imp #( transaction, scoreboard ) imp;

        int unsigned n_checked, n_fail;
        
        int unsigned n_ontime_in, n_late_in, n_leave, n_early_out, n_ontime_out;
        
        transaction cov;  //For coverage
        
        typedef struct{
                bit login;
                bit late_login;
                bit intime_login;
                bit early_logout;
                bit on_leave;
                bit ontime_out;
        } rtl_exp_s;
        
        
        covergroup cg;
        
                option.per_instance = 1;
                
                hr_in1 : coverpoint cov.hr_in1 {
                        bins sched1 = {9};
                        bins sched2 = {10};      // 10 on the 9-6 port
                        bins before_9  = {[0:8]};
                        bins after_10  = {[11:15]};
                }
                
                hr_in2 : coverpoint cov.hr_in2 {
                        bins sched2 = {10};
                        bins sched1 = {9};      // 9 on the 10-7 port
                        bins below_9   = {[0:8]};
                        bins above_10  = {[11:15]};
                }
                
                min_in : coverpoint cov.min_in {
                        bins on_time    = {0};
                        bins late_first = {1};
                        bins late_mid   = {[2:58]};
                        bins late_last  = {59};
                        bins illegal    = {[60:63]};
                }
                
                hr_out : coverpoint cov.hr_out  {
                        bins zero      = {0};
                        bins early_lo  = {[1:4]};
                        bins h5        = {5};
                        bins h6        = {6};
                        bins h7        = {7};
                        bins h8_12     = {[8:12]};
                        bins h13_15    = {[13:15]};
                }
                
                min_out : coverpoint cov.min_out {
                        bins zero    = {0};
                        bins mid     = {[1:58]};
                        bins last    = {59};
                        bins illegal = {[60:63]};
                }
                
        endgroup : cg        

        
        function new( string name = "scoreboard", uvm_component parent );
                
                super.new( name, parent );
                
                cg = new();
                
        endfunction : new
        

        function void build_phase( uvm_phase phase );
                
                super.build_phase( phase );
                
                imp = new( "imp", this );
                
        endfunction : build_phase
        

        function bit chk( string sig, logic got, bit exp_v, transaction tx );
        
                if ( got !== exp_v ) 
                begin
                        `uvm_error( "SB_MISMATCH", $sformatf( "%s: got = %0d expected = %0d | %s", sig, got, exp_v, tx.sprint() ) )
                        return 0;
                end
                
                return 1;
        
        endfunction : chk
        
        
        function automatic rtl_exp_s rtl_predict( bit [3:0] hr_in1, bit [3:0] hr_in2,
                                                        bit [5:0] min_in, bit [3:0] hr_out );
                rtl_exp_s e;
                
                bit sch1, sch2, min_ok, login_ok;
                
                bit [3:0] thr;
                
                //sch1     = ( hr_in1 == 9 );
                
                sch1     = ( hr_in1 <= 9 );
                
                //sch2     = ( hr_in2 == 10 );
                
                sch2     = ( hr_in2 <= 10 );                
                
                min_ok   = ( min_in <= 59 );
                
                login_ok = min_ok && (sch1 || sch2);
                
                thr      = sch1 ? 6 : 7;   // 9-6 has priority
                
                e.login        = login_ok;
                
                e.intime_login = login_ok && ( min_in == 0 );
                
                e.late_login   = login_ok && ( min_in != 0 );
                
                e.on_leave     = !login_ok;
                
                e.ontime_out   = login_ok && ( hr_out >= thr );
                
                e.early_logout = login_ok && ( hr_out <  thr );
                
                return e;
        
        endfunction : rtl_predict
        
        bit first_skipped;     // set after the idle initial cycle has been dropped

        function void write( transaction t );
  
                rtl_exp_s e;
                
                bit ok;
                
                if (!first_skipped)           // 15 ns idle cycle: ignore it
                begin
                        first_skipped = 1;
                        return;
                end
                
                e  = rtl_predict( t.hr_in1, t.hr_in2, t.min_in, t.hr_out );
                
                ok = 1;
                
                n_checked++;
                
                cov = t;
                
                cg.sample();
                
                ok &= chk( "login",        t.login,        e.login,        t );
                
                ok &= chk( "late_login",   t.late_login,   e.late_login,   t );
                
                ok &= chk( "intime_login", t.intime_login, e.intime_login, t );
                
                ok &= chk( "early_logout", t.early_logout, e.early_logout, t );
                
                ok &= chk( "on_leave",     t.on_leave,     e.on_leave,     t );
                
                ok &= chk( "ontime_out",   t.ontime_out,   e.ontime_out,   t );
                
                if ( !ok ) 
                begin
                        n_fail++;
                end        
                
                // statistics of what was actually exercised ( from the expected values )
                if( e.intime_login )
                begin 
                        n_ontime_in++;
                end
                
                if( e.late_login )
                begin
                        n_late_in++;
                end
                        
                if( e.on_leave )
                begin     
                        n_leave++;
                end
                        
                if( e.early_logout )
                begin 
                        n_early_out++;
                end
                        
                if( e.ontime_out )   
                begin
                        n_ontime_out++;
                end        
                
        endfunction : write


        function void report_phase( uvm_phase phase );
        
                `uvm_info( get_type_name(), $sformatf( 
                "checked = %0d, failed = %0d, ontime_in = %0d, late_in = %0d, on_leave = %0d, early_out = %0d, ontime_out = %0d \n",
                n_checked, n_fail, n_ontime_in, n_late_in, n_leave, n_early_out, n_ontime_out ), UVM_LOW )
                
                if ( n_fail == 0 && n_checked > 0 )
                begin
                        `uvm_info( get_type_name(), "TEST PASSED", UVM_LOW )
                end 
                 
                else
                begin
                        `uvm_info( get_type_name(), "TEST FAILED", UVM_LOW )
                end
        
        endfunction : report_phase
  
endclass : scoreboard

















