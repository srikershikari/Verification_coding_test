/********************************************************************************************
Filename    :	   agent.sv   

Description :      agent class

Author Name :      Sriker

Version     :      1.7
*********************************************************************************************/
class agent extends uvm_agent;

        `uvm_component_utils( agent )
        
        driver    drv;
        monitor   mon;
        sequencer sqr;

        function new( string name = "agent", uvm_component parent );
        
                super.new( name, parent );
                
        endfunction : new

        function void build_phase( uvm_phase phase );
                
                super.build_phase( phase );
                
                mon = monitor::type_id::create( "mon", this );
                
                if ( get_is_active() == UVM_ACTIVE ) 
                begin
                        drv = driver::type_id::create( "drv", this );                        
                        sqr = sequencer::type_id::create( "sqr", this );
                end
                
        endfunction : build_phase
        

        function void connect_phase( uvm_phase phase );
                
                if( get_is_active() == UVM_ACTIVE )
                begin
                        drv.seq_item_port.connect( sqr.seq_item_export );
                end
                
        endfunction : connect_phase
        
endclass : agent








































