/********************************************************************************************
Filename    :	   test.sv   

Description :      test class

Author Name :      Sriker

Version     :      1.10
*********************************************************************************************/
class base_test extends uvm_test;
        
        `uvm_component_utils( base_test )
        
        env        envh;
        
        virtual rtl_if vif;

        function new( string name = "base_test", uvm_component parent );
                
                super.new( name, parent );
                
        endfunction : new
        

        function void build_phase( uvm_phase phase );
                
                super.build_phase( phase );
                
                envh = env :: type_id :: create( "envh", this );
                
                if ( !uvm_config_db#( virtual rtl_if )::get( this, "", "vif", vif ) )
                begin
                        `uvm_fatal( get_type_name(), "Error while getting virtual interface" )
                end
                
        endfunction : build_phase
        

        function void end_of_elaboration_phase( uvm_phase phase );
                
                $display("printing topology from test class \n");
        
                uvm_top.print_topology(  );
                
        endfunction : end_of_elaboration_phase
       
endclass : base_test


class pos_test extends base_test;
          
          `uvm_component_utils( pos_test )
          
        function new( string name = "pos_test", uvm_component parent ); 

                super.new( name, parent ); 

        endfunction : new
        
          
        task run_phase( uvm_phase phase );

                pos_seq seq = pos_seq :: type_id :: create( "pos_seq" );

                phase.raise_objection( this );

                seq.start( envh.agt.sqr );

                repeat ( 5 ) @( posedge vif.clk );        // drain: let the last responses reach the monitor

                phase.drop_objection( this );

        endtask
  
endclass : pos_test


class neg_test extends base_test;

        `uvm_component_utils( neg_test )
        
        function new( string name = "neg_test", uvm_component parent ); 
                
                super.new( name, parent );
                
        endfunction : new
        
        
        task run_phase( uvm_phase phase );
        
                neg_seq seq = neg_seq :: type_id :: create( "neg_seq" );
                
                phase.raise_objection( this );

                seq.start( envh.agt.sqr );

                repeat ( 5 ) @( posedge vif.clk );        // drain: let the last responses reach the monitor

                phase.drop_objection( this );
                
        endtask
        
endclass : neg_test


class corner_test extends base_test;

        `uvm_component_utils( corner_test )
        
        function new( string name = "corner_test", uvm_component parent ); 
                
                super.new( name, parent ); 
                
        endfunction : new
        
        task run_phase( uvm_phase phase );
                
                corner_seq seq = corner_seq :: type_id :: create( "corner_seq" );
                
                phase.raise_objection( this );

                seq.start( envh.agt.sqr );

                repeat ( 5 ) @( posedge vif.clk );        // drain: let the last responses reach the monitor

                phase.drop_objection( this );
                
        endtask : run_phase
        
endclass : corner_test





















