//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0
    localparam sqrt_latency = 16;

    logic [31:0] sqrt_c;
    logic sqrt_c_vld;

    logic [31:0] sqrt_b;
    logic sqrt_b_vld;

    logic [31:0] b_shifted;
    logic b_shifted_vld;

    logic [31:0] a_shifted;
    logic a_shifted_vld;
    
    logic [31:0] b_sum, a_sum;


    isqrt #(.n_pipe_stages(sqrt_latency)) isqrt_c
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x     ( c),
        .x_vld ( arg_vld ),
        .y (sqrt_c),
        .y_vld ( sqrt_c_vld )
    );


    shift_register_with_valid  #( .width(32), .depth(sqrt_latency )) shift_register_b
    (
        .clk (clk),
        .rst (rst),
        .in_data (b),
        .in_vld(arg_vld),
        .out_data(b_shifted),
        .out_vld(b_shifted_vld)
    );

    shift_register_with_valid  #( .width(32), .depth(2*sqrt_latency )) shift_register_a
    (
        .clk (clk),
        .rst (rst),
        .in_data (a),
        .in_vld(arg_vld),
        .out_data(a_shifted),
        .out_vld(a_shifted_vld)
    );

    assign b_sum = b_shifted +  32' (sqrt_c);

    isqrt  #(.n_pipe_stages(sqrt_latency)) isqrt_b
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x     ( b_sum),
        .x_vld ( b_shifted_vld ),
        .y (sqrt_b),
        .y_vld ( sqrt_b_vld )
    );

    assign a_sum = a_shifted + 32' (sqrt_b);

    isqrt  #(.n_pipe_stages(sqrt_latency)) isqrt_a
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x     ( a_sum),
        .x_vld ( a_shifted_vld ),
        .y (res),
        .y_vld ( res_vld)
    );





endmodule
