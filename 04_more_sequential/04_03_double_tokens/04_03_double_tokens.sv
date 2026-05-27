//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110
    localparam max_doubling_size = 200;
    localparam counter_width = $clog2(max_doubling_size + 1);

    logic [counter_width - 1:0] counter_reg;
    logic overflow_reg;
    logic overflow_l;
    logic counter_is_zero;
    logic b_l;
    
    assign max_l = (counter_reg == max_doubling_size);
    assign counter_is_zero = (counter_reg == 0);
    assign overflow = (a && max_l) || overflow_reg;
    
    always_comb
    begin
       if (a) begin
          b_l = 1;
       end
       else
       begin
          b_l = !counter_is_zero;
       end

    end 

    assign b = b_l;
  
    always_ff @ (posedge clk)
    if (rst ) begin
      counter_reg <= 0;
      overflow_reg <= 0;
    end
    else begin
       overflow_reg <= overflow;
       if (a) begin
         if (!max_l) 
           counter_reg <= counter_reg + 1;
       end
       else begin
         if (!counter_is_zero)
           counter_reg <= counter_reg - 1;
       end

    end 


endmodule
