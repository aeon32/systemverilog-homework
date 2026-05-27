//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module conv_first_to_last_no_ready
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input                up_valid,
    input                up_first,
    input  [width - 1:0] up_data,

    output               down_valid,
    output               down_last,
    output [width - 1:0] down_data
);
    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // See README for full description of the task with timing diagram.
   logic [width - 1 : 0] last_valid_data_reg;
   logic has_last_valid_data_reg;

   assign down_valid = up_valid  && has_last_valid_data_reg; 
   assign down_data = last_valid_data_reg;
   assign down_last = up_valid && up_first && has_last_valid_data_reg;


   always_ff @ (posedge clock)
   if (reset)
     has_last_valid_data_reg <= '0;
   else if (up_valid) begin
     has_last_valid_data_reg <=1;
     last_valid_data_reg <= up_data;
   end
   else begin
     //has_last_valid_data_reg <=0;  
   end
     

   

endmodule
