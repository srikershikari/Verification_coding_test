/********************************************************************************************
Filename    :	   sequencer.sv   

Description :      sequencer class

Author Name :      Sriker

Version     :      1.6
*********************************************************************************************/
class sequencer extends uvm_sequencer #( transaction );

        `uvm_component_utils( sequencer )
        
        function new( string name = "sequencer", uvm_component parent );
        
                super.new( name, parent );
                
        endfunction
        
endclass : sequencer        