/********************************************************************************************
Filename    :	   transaction.sv   

Description :      transaction class

Author Name :      Sriker

Version     :      1.2
*********************************************************************************************/
class transaction extends uvm_sequence_item;

        `uvm_object_utils( transaction )

        rand bit [ 3 : 0 ] hr_in1, hr_in2, hr_out;
        
        rand bit [ 5 : 0 ] min_in, min_out;

        logic login, late_login, intime_login, early_logout, on_leave, ontime_out;

        constraint c1 
        { 
                min_in <= 6'd63;
                min_out <= 6'd63;
                
                //min_in <= 6'd59;
                //min_out <= 6'd59;  
        }

        function new( string name = "transaction" );
        
                super.new( name );
                
        endfunction : new
        
        
        function void do_print( uvm_printer printer );

	        super.do_print( printer );
	        
	                           //STRING NAME, VALUE,        SIZE,           RADIX
	        printer.print_field( "hr_in1", this.hr_in1, $bits( hr_in1 ), UVM_DEC );
	        
	        printer.print_field( "hr_in2", this.hr_in2, $bits( hr_in2 ), UVM_DEC );
	        
	        printer.print_field( "min_in", this.min_in, $bits( min_in ), UVM_DEC );
	        
	        printer.print_field( "login", this.login, $bits( login ), UVM_BIN );
	        
	        printer.print_field( "hr_out", this.hr_out, $bits( hr_out ), UVM_DEC );
	        
	        printer.print_field( "min_out", this.min_out, $bits( min_out ), UVM_DEC );
	        
	        printer.print_field( "late_login", this.late_login, $bits( late_login ), UVM_BIN );
	        
	        printer.print_field( "intime_login", this.intime_login, $bits( intime_login ), UVM_BIN );
	        
	        printer.print_field( "early_logout", this.early_logout, $bits( early_logout ), UVM_BIN );
	        
	        printer.print_field( "on_leave", this.on_leave, $bits( on_leave ), UVM_BIN );
	        
	        printer.print_field( "ontime_out", this.ontime_out, $bits( ontime_out ), UVM_BIN );	        
	
        endfunction : do_print
        
endclass : transaction





















