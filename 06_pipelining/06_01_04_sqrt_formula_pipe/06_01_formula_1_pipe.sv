//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
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
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
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
    logic [31:0] y_a, y_b, y_c;

    isqrt sqrt_a
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x     ( a),
        .x_vld ( arg_vld ),
        .y (y_a),
        .y_vld ( res_vld )
    );

    isqrt sqrt_b
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x     ( b),
        .x_vld ( arg_vld ),
        .y (y_b)
    );

    isqrt sqrt_c
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x     ( c),
        .x_vld ( arg_vld ),
        .y (y_c)
    );

    assign res = 32' (y_a) + 32' (y_b) + 32' (y_c);


endmodule
