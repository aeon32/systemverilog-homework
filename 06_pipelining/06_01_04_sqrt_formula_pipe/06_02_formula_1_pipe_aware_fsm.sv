//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0
    logic [31:0] x, y, res_reg;
    logic [1:0][31:0] x_reg;

    logic x_vld, y_vld;
    logic [2:0] x_counter, next_x_counter, y_counter, next_y_counter;

    isqrt sqrt_a
    (
        .clk   ( clk ),
        .rst   ( rst ),
        .x     ( x),
        .x_vld ( x_vld ),
        .y (y),
        .y_vld ( y_vld )
    );

    always_comb
    begin
        next_x_counter = x_counter;
        next_y_counter = y_counter;
        x_vld = 0;
        res_vld = 0;
        res = res_reg;

        if (x_counter == 0)
        begin
            if (arg_vld)
            begin
                x = a;
                x_vld = 1;
                next_x_counter = 2; //2 items in the queue
                next_y_counter = 3;
                res = 0;
            end
        end
        else
        begin
            x_vld = 1;
            next_x_counter = x_counter - 1;
            x = x_reg[next_x_counter];
        end
        
        if (y_vld)
        begin
            next_y_counter = y_counter - 1;
            res = y + res_reg;
            res_vld = y_counter == 1;
        end


    end

  always_ff @ (posedge clk)
    if (rst)
    begin
        x_counter <= 0;
        y_counter <= 0;
    end
    else
    begin
        x_counter <= next_x_counter;
        y_counter <= next_y_counter;
        res_reg <= res;
        if (arg_vld)
        begin
            x_reg[1] <=b;
            x_reg[0] <=c;
        end
    end


endmodule
