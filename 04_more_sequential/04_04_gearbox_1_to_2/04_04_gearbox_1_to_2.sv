//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2
# (
    parameter width = 0
)
(
    input                    clk,
    input                    rst,

    input                    up_vld,    // upstream
    input  [    width - 1:0] up_data,

    output                   down_vld,  // downstream
    output [2 * width - 1:0] down_data
);
    // Task:
    // Implement a module that transforms a stream of data
    // from 'width' to the 2*'width' data width.
    //
    // The module should be capable to accept new data at each
    // clock cycle and produce concatenated 'down_data'
    // at each second clock cycle.
    //
    // The module should work properly with reset 'rst'
    // and valid 'vld' signals

    logic [ width - 1 : 0] data_reg;
    logic have_first_half_reg;

    assign down_data = { data_reg, up_data};
    assign down_vld = up_vld && have_first_half_reg;

    always_ff @ (posedge clk)
    if (rst ) begin
      have_first_half_reg <= 0;
    
    end
    else begin 
       if (up_vld) begin
         if (!have_first_half_reg) begin
            data_reg <= up_data;
         end
         have_first_half_reg <= ! have_first_half_reg;
       end
    end




endmodule
