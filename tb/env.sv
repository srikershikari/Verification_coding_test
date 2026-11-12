/********************************************************************************************
Filename    :	   env.sv   

Description :      env class

Author Name :      Sriker

Version     :      1.9
*********************************************************************************************/
class env extends uvm_env;
        
        `uvm_component_utils( env )
        
        agent      agt;
        scoreboard sb;

        function new( string name = "env", uvm_component parent );
                
                super.new( name, parent );
                
        endfunction : new
        

        function void build_phase( uvm_phase phase );
        
                super.build_phase( phase );
                
                agt = agent::type_id::create( "agt", this );
                
                sb  = scoreboard::type_id::create( "sb", this );
                
        endfunction : build_phase
        

        function void connect_phase( uvm_phase phase );
                
                super.connect_phase( phase );
                
                agt.mon.ap.connect( sb.imp );
                
        endfunction : connect_phase
  
endclass : env




















