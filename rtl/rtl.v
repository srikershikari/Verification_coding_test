/*

This module implements a simple employee login-logout tracking system based on clock-in and clock-out times 

the working hours are either 9-6(using hr_in1) or 10-7(using hr_in2).

Logic conditions
-> If the employee logs in the at the exact hour with min_in = 0, it is considered an ontime login
-> if the employee logs in with min_in between 1 and 59 it is considered a late login.( signaled by late_login = 1 )
-> If the employee does not login within the hour they are marked on leave

Logout conditions 
-> If the employee logs out at or after 6PM for a 9-6 schedule 
or at or after 7PM for a 10-7 schedule they are considered to have logged on time.

-> If the employee logs out before these times, it is marked as early log out

The module outputs flags for 
login - Employee has logged in
intime_login - on-time login
late_login - late login( combinational output )
early_logout - employee logged out early
ontime_out - ontime lohout
on_leave - employee absent

ALL operations are synchronous with the posedge of clock clk

*/

module rtl(
        input clk,
        
        input [ 3 : 0 ]hr_in1, //for 9-6
        
        input [ 3 : 0 ]hr_in2, //for 10-7
        
        input [ 5 : 0 ]min_in,
        
        output reg login,
        
        input [ 3 : 0 ]hr_out,
        
        input [ 5 : 0 ]min_out,
        
        output late_login,
        
        output reg intime_login,
        
        output reg early_logout,
        
        output reg on_leave,
        
        output reg ontime_out       
);

assign late_login = ( ( hr_in1 >= 9 || hr_in2 >= 10 ) &&
                        ( min_in >= 1 && min_in <= 59 ) ) ? 1'b1 : 1'b0;
                        
//login and leave tracking
always @( posedge clk )
begin
        if(  hr_in1 <= 9 || hr_in2 <= 10 ) //9-6 or 10-7
        begin
                if( min_in == 0 )
                begin
                        intime_login <= 1;
                        
                        login <= 1;
                        
                        on_leave <= 0;
                end
                
                else if( min_in >= 1 && min_in <= 59 )
                begin
                        intime_login <= 1;
                        
                        login <= 1;
                        
                        on_leave <= 0;
                
                end
                
                else
                begin
                        intime_login <= 0;
                        
                        login <= 0;
                        
                        on_leave <= 1;                
                
                end
        
        end
        
        else
        begin
                intime_login <= 0;
                
                login <= 0;
                
                on_leave <= 0;        
        
        end

end


//Logout tracking
always @( posedge clk )
begin
        if( ( ( hr_in1 <= 9 && hr_out >= 6 ) ||
                 ( hr_in2 <= 10 && hr_out >= 7 ) ) && ( min_out >= 0 )
         )
         begin
                ontime_out <= 1;
                
                early_logout <= 0;
         end
         
         else
         begin
                ontime_out <= 0;
                
                early_logout <= 1;                
         
         end
        
end

endmodule