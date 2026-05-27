//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts single-bit serial data to the multi-bit parallel value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits and receiving last 'serial_valid' input,
    // the module should assert the 'parallel_valid' at the same clock cycle
    // and output 'parallel_data' value.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    localparam pointer_width = $clog2(width);
    logic [width - 1:0] parallel_data_r;
    logic [width - 1:0] parallel_data_l;
  

    logic [pointer_width - 1 : 0] data_pointer_r;

    
    assign parallel_valid = (data_pointer_r == (width - 1)) && serial_valid;
    assign parallel_data = {serial_data, parallel_data_r[width-1:1]};
    
    always_ff @ (posedge clk)
    if (rst) begin
      parallel_data_r <= {width{1'b0}};
      data_pointer_r <= 0;
    end
    else begin
      if (serial_valid) begin
        parallel_data_r <= parallel_data;
        data_pointer_r <= (parallel_valid) ? 0 : data_pointer_r + 1 ;
          
      end  
    end


endmodule
