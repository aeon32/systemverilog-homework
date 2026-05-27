//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.
  logic [3:0] aux_sum;
  assign aux_sum = a + b;
  
  logic [3:0] MAX_VALUE = 4'b0111;
  logic [3:0] MIN_VALUE = 4'b1000;
  logic [3:0] out_sum;


  always @* begin
     if (!a[3] && !b[3] && aux_sum[3]) 
        out_sum = MAX_VALUE;
     else if (a[3] && b[3] && !aux_sum[3])
        out_sum = MIN_VALUE;
     else 
        out_sum = aux_sum;
  end
    
  assign sum = out_sum;





endmodule
