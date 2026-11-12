/********************************************************************************************
Filename    :	   driver.sv   

Description :      driver class

Author Name :      Sriker

Version     :      1.4
*********************************************************************************************/
class driver extends uvm_driver #( transaction );

        `uvm_component_utils( driver )
        
        virtual rtl_if vif;

        function new( string name = "driver", uvm_component parent );
        
                super.new( name, parent );
                
        endfunction : new
        

        function void build_phase( uvm_phase phase );
        
                super.build_phase( phase );
                
                if ( !uvm_config_db#( virtual rtl_if )::get( this, "", "vif", vif ) )
                begin
                        `uvm_fatal( get_type_name(), "Error while getting virtual interface" )
                end
                
        endfunction : build_phase
        

        task run_phase( uvm_phase phase );
                
                forever 
                begin
                        seq_item_port.get_next_item( req );
                        send_to_dut( req );
                        seq_item_port.item_done();
                end
                
        endtask : run_phase
        

        task send_to_dut( transaction tx );
                
                @( vif.drv_cb );                       // one item per cycle
                vif.drv_cb.hr_in1  <= tx.hr_in1;
                vif.drv_cb.hr_in2  <= tx.hr_in2;
                vif.drv_cb.min_in  <= tx.min_in;
                vif.drv_cb.hr_out  <= tx.hr_out;
                vif.drv_cb.min_out <= tx.min_out;
                
	`uvm_info( get_type_name(), $sformatf( "the transaction sent to dut is \n %s", tx.sprint() ), UVM_LOW )                
                        
        endtask : send_to_dut
        
endclass : driver



















