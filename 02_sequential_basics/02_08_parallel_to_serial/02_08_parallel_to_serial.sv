//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module parallel_to_serial
# (
    parameter width = 8
)
(                                                                        
    input                      clk,
    input                      rst,

    input                      parallel_valid,
    input        [width - 1:0] parallel_data,

    output                     busy,
    output logic               serial_valid,
    output logic               serial_data
);
    // Task:
    // Implement a module that converts multi-bit parallel value to the single-bit serial data.
    //
    // The module should accept 'width' bit input parallel data when 'parallel_valid' input is asserted.
    // At the same clock cycle as 'parallel_valid' is asserted, the module should output
    // the least significant bit of the input data. In the following clock cycles the module
    // should output all the remaining bits of the parallel_data.
    // Together with providing correct 'serial_data' value, module should also assert the 'serial_valid' output.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
      localparam counter_width = $clog2(width);

      logic [width - 2:0] data_r;
      logic [counter_width - 1 : 0 ] counter_r;
      logic busy_l;
      logic busy_r;
      logic serial_data_l;
      logic over;

      assign serial_valid = parallel_valid || busy_r;
      assign serial_data = busy_r ?  data_r[0] : parallel_data[0];

      assign busy = busy_r;
      assign over = (counter_r == (width - 1 ));



      always_ff @ (posedge clk)
        if (rst ) begin
            counter_r <= 0;
            busy_r <= 0;
        end
        else if (~busy_r & parallel_valid) begin
            data_r <= parallel_data[width - 1 : 1];
            busy_r <= 1;
            counter_r <=1;
        end
        else if (busy_r)
        begin
            data_r <= data_r >> 1;
            busy_r <= over ? 0 : 1;
            counter_r <= over ? 0 : counter_r + 1;
        end

endmodule
