/********************************************************************************************
Filename    :	   sequence.sv   

Description :      sequence class

Author Name :      Sriker

Version     :      1.3
*********************************************************************************************/
class base_seq extends uvm_sequence #( transaction );

        `uvm_object_utils( base_seq )
        
        int unsigned n_rand = 100;

        function new( string name = "base_seq" );
                
                super.new( name );
                
        endfunction : new
        

        task send( bit [3:0] a_hr_in1, bit [3:0] a_hr_in2, bit [5:0] a_min_in,
                        bit [3:0] a_hr_out, bit [5:0] a_min_out );
        
                transaction req = transaction :: type_id :: create( "req" );
                
                start_item( req );
                
                assert( req.randomize(  ) with { hr_in1 == a_hr_in1; hr_in2 == a_hr_in2; min_in == a_min_in; 
                                                        hr_out == a_hr_out; min_out == a_min_out; } );
                
                finish_item( req );
        
        endtask : send
  
endclass : base_seq


class pos_seq extends base_seq;
        
        `uvm_object_utils( pos_seq )
        
        function new( string name = "pos_seq" ); 
                
                super.new( name ); 
                
        endfunction : new


        task body(  );
                
                `uvm_info( get_type_name(  ), "Positive sequence start \n", UVM_LOW )
                
                
                send( 9, 0,  0, 6,  0 );   // on-time in, on-time out ( exactly 6 )
                
                send( 9, 0,  0, 8, 30 );   // on-time in, stay late
                
                send( 0, 10,  0, 7,  0 );  // on-time in, on-time out ( exactly 7 )
                
                /* send( 9, 0,  0, 4,  0 );   // on-time in, early out
                
                send( 9, 0, 30, 6, 30 );   // late in,    on-time out
                
                send( 9, 0, 15, 3, 45 );   // late in,    early out
                
                send( 0, 10,  0, 9, 15 );  // on-time in, stay late
                
                send( 0, 10,  0, 5,  0 );  // on-time in, early out
                
                send( 0, 10, 20, 7, 30 );  // late in,    on-time out
                
                send( 0, 10, 45, 6, 59 );  // late in,    early out ( 6 is early for 10-7 )
                
                repeat( n_rand ) 
                begin
                      transaction req = transaction :: type_id :: create( "req" );
                      
                      start_item( req );
                      
                      assert( req.randomize() with {
                            ( (hr_in1 == 9)^(hr_in2 == 10) );
                            min_in  dist {0 := 30, [1:59] :/ 70};
                            hr_out  inside {[1:12]};
                          } );
                        
                      finish_item( req );
                end */
                
                `uvm_info( get_type_name(), "Positive sequence done \n", UVM_LOW )
                
        endtask : body
        
endclass : pos_seq


class neg_seq extends base_seq;
        
        `uvm_object_utils( neg_seq )
        
        function new( string name = "neg_seq" ); 
                
                super.new( name ); 
                
        endfunction : new

        task body();
        
                `uvm_info( get_type_name(), "Negative sequence start \n", UVM_LOW )
                
                send(  8,  9, 0, 6, 0 );   // early: before both schedules
                
                send( 11, 11, 0, 7, 0 );   // late: after both schedules
               
                send( 15, 15, 59, 15, 59 );
                
                
                /* repeat ( n_rand ) 
                begin
                        transaction req = transaction :: type_id :: create( "req" );
                        
                        start_item( req );
                        
                        assert( req.randomize() with {
                                hr_in1 != 9;
                                hr_in2 != 10;
                                min_in inside {[0:63]};
                                min_out inside {[0:63]};
                        });
                        
                        finish_item( req );
                end */
    
               
                `uvm_info( get_type_name(), "Negative sequence done \n", UVM_LOW )
        
        endtask
  
endclass : neg_seq


class corner_seq extends base_seq;

        `uvm_object_utils( corner_seq )
        
        function new( string name = "corner_seq" ); 
                
                super.new( name ); 

        endfunction : new

        task body(  );
        
                `uvm_info( get_type_name(  ), "Corner sequence start \n", UVM_LOW )
                
                send( 9, 0, 63, 6, 0 );
                
                send( 0, 10, 63, 7, 0 );
                
                send( 15, 15, 59, 15, 59 );  
                
                send( 9, 0, 2, 0, 0 ); //late_login, intime_login
                
                send( 0, 0, 0, 0, 0 );
                
                `uvm_info( get_type_name(), "Corner sequence done \n", UVM_LOW )

        endtask

endclass : corner_seq



























