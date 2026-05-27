//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01
    logic prev_grant;
    logic grant;
    logic [1:0] grants_l;

    always_comb
    begin
      case (requests)
        2'b00: grant = prev_grant;
        2'b01: grant = 0;
        2'b10: grant = 1;
        2'b11: grant = ~prev_grant;
      endcase

      case ({|requests, grant})
        2'b10: grants_l = 2'b01;
        2'b11: grants_l = 2'b10;
        default:grants_l = 2'b00;
      endcase

    end
    assign grants = grants_l;      

    always_ff @ (posedge clk)
    if (rst)
      prev_grant <= 1'b1;
    else
      prev_grant <= grant;

endmodule
