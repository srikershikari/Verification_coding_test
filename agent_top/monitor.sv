/********************************************************************************************
Filename    :	   monitor.sv   

Description :      monitor class

Author Name :      Sriker

Version     :      1.5
*********************************************************************************************/
class monitor extends uvm_monitor;

        `uvm_component_utils( monitor )
        
        virtual rtl_if vif;
        
        uvm_analysis_port #( transaction ) ap;

        function new( string name = "monitor", uvm_component parent );
                
                super.new( name, parent );
                
        endfunction : new
        

        function void build_phase( uvm_phase phase );
                
                super.build_phase( phase );
                
                ap = new( "ap", this );
                
                if ( !uvm_config_db#( virtual rtl_if )::get( this, "", "vif", vif ) )
                begin
                        `uvm_fatal( get_type_name(), "Error while getting virtual interface" )
                end
                
        endfunction : build_phase
        

        task run_phase( uvm_phase phase );
                
                transaction prev, cur;
                
                forever 
                begin
                        @( vif.mon_cb );
                        
                        cur = transaction :: type_id :: create( "cur" );
                        
                        cur.hr_in1     = vif.mon_cb.hr_in1;
                        cur.hr_in2     = vif.mon_cb.hr_in2;
                        cur.min_in     = vif.mon_cb.min_in;
                        cur.hr_out     = vif.mon_cb.hr_out;
                        cur.min_out    = vif.mon_cb.min_out;
                        cur.late_login = vif.mon_cb.late_login;   // combinational: same-cycle
                        
                        if ( prev != null )                     // registered: previous-cycle result
                        begin
                                prev.login        = vif.mon_cb.login;
                                prev.intime_login = vif.mon_cb.intime_login;
                                prev.early_logout = vif.mon_cb.early_logout;
                                prev.on_leave     = vif.mon_cb.on_leave;
                                prev.ontime_out   = vif.mon_cb.ontime_out;
                                
                                `uvm_info( get_type_name(), $sformatf( "the transaction from dut to monitor is \n %s", prev.sprint() ), UVM_LOW )
                                
                                ap.write( prev );
                        end
                
                        prev = cur;
                
                end
                
        endtask : run_phase
        
endclass : monitor


/*
Here is one stimulus followed step by step. The clock edges are at 5, 15, 25 ns, and so on.

Time	What happens
5 ns (edge)	The driver gets the item and schedules the pins to change 1 ns later.
6 ns	The pins now hold the new inputs. They stay stable until 16 ns.
15 ns (edge)	Two things happen at this edge. DUT: it captures the inputs, and its registered outputs change just after the edge. 
                Monitor: it samples before the edge, so it sees the inputs from 6 ns but still the old outputs. It stores these inputs in cur.
25 ns (edge)	The monitor samples again and now sees the outputs that changed just after 15 ns. It attaches them to the stored inputs (prev) and publishes the complete transaction.

The rule behind it

A register changes just after its clock edge. A sampler reading before the same edge sees the value from before that change.
So the DUT needs one edge to capture the inputs, and the monitor needs the next edge to see the result.
That is two edges (20 ns) from the driver’s edge to the published transaction.

Why the monitor keeps prev

At the 15 ns edge the monitor sees the inputs but not their result yet.
It holds those inputs as prev until 25 ns, when the result is available.
It then publishes both together.

The 20 ns delay holds for every stimulus: 15 ns gives 35 ns, 25 ns gives 45 ns, and so on.




What happened

At 5 ns the monitor samples the inputs. The driver hasn’t driven yet (it only drives after the first edge), so the input pins are unknown (X) at that point.
The monitor stores that sample in cur and, at the end of the 5 ns edge, prev = cur. That is why the print shows the object name cur.
At the same 5 ns edge the DUT captures those X inputs.
At 15 ns the monitor samples the registered outputs, which are the DUT’s response to the X inputs from 5 ns. It attaches them to the stored object and prints it.

Why the values look the way they do

late_login = 'bx: it is combinational and has the same X inputs, so it stays X. The field is a 4-state logic.
Inputs show 'd0: your transaction’s input fields are 2-state types. Assigning an X to them turns it into 0, so the print shows 0 even though the pins were X.
Outputs: in your RTL, an if whose condition is X takes the else branch. The login block’s else gives login=0, intime_login=0 and on_leave=0. The logout block’s else gives ontime_out=0 and early_logout=1. That is exactly what the print shows.


*/


















