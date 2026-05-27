//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.
    localparam [FLEN - 1:0] four = 64'h4010_0000_0000_0000;

    logic [FLEN - 1:0] multbb_res;
    logic multbb_up_valid, multbb_down_valid, multbb_busy, multbb_error;

    logic [FLEN - 1:0] multac_res;
    logic multac_up_valid, multac_down_valid, multac_busy, multac_error;

    logic [FLEN - 1:0] mult4ac_res;
    logic  mult4ac_down_valid, mult4ac_busy, mult4ac_error;

    logic [FLEN - 1:0] multbb_res_reg, mult4ac_res_reg;
    logic multbb_res_ready, mult4ac_res_ready, mult4ac_error_reg, multbb_error_reg;

    logic [FLEN - 1:0] sub_res;
    logic sub_up_valid, sub_down_valid, sub_error;

     f_mult mult_b_b (
        .clk (clk),
        .rst(rst),
        .a(b),
        .b(b),
        .up_valid(multbb_up_valid),
        .down_valid(multbb_down_valid),
        .busy(multbb_busy),
        .error(multbb_error),
        .res(multbb_res)
    );

     f_mult mult_a_c (
        .clk (clk),
        .rst(rst),
        .a(a),
        .b(c),
        .up_valid(multac_up_valid),
        .down_valid(multac_down_valid),
        .busy(multac_busy),
        .error(multac_error),
        .res(multac_res)
    );

  f_mult mult_4_a_c (
        .clk (clk),
        .rst(rst),
        .a(four),
        .b(multac_res),
        .up_valid(multac_down_valid),
        .down_valid(mult4ac_down_valid),
        .busy(mult4ac_busy),
        .error(mult4ac_error),
        .res(mult4ac_res)
    );
    f_sub sub (
        .clk(clk),
        .rst(rst),
        .a(multbb_res_reg),
        .b(mult4ac_res_reg),
        .up_valid(sub_up_valid),
        .down_valid(sub_down_valid),
        .error(sub_error),
        .res(sub_res)
    );


     enum logic [2:0]
    {
        st_init       = 3'd0,
        st_wait_muls = 3'd1,
        st_wait_sub =  3'd2
    } state, next_state;


    always_comb
    begin
        next_state  = state;
        multbb_up_valid = 0;
        multac_up_valid = 0;
        sub_up_valid = 0;
 
        // This lint warning is bogus because we assign the default value above
        // verilator lint_off CASEINCOMPLETE

        case (state)
            st_init:
            begin
                if (arg_vld)
                begin
                    multbb_up_valid = '1;
                    multac_up_valid = '1;
                    next_state = st_wait_muls;
                end
            end

            st_wait_muls:
            begin
                if (mult4ac_res_ready && multbb_res_ready)
                begin
                    if (mult4ac_error_reg || multbb_error_reg)
                        next_state = st_init;
                    else
                    begin
                        sub_up_valid = 1;
                        next_state = st_wait_sub;
                    end
                end
            end

            st_wait_sub:
            begin
                if (sub_down_valid)
                    next_state = st_init;
            end

        endcase
    end
    
    assign res_vld = (state != st_init && next_state == st_init);
    assign res = sub_res;
    assign err = mult4ac_error_reg || multbb_error_reg || sub_error;
    assign busy = (state != st_init) && (next_state != st_init);


    always_ff @ (posedge clk)
    if (rst)
    begin
        state <= st_init;
    end
    else
        state <= next_state;    

    always_ff @ (posedge clk)
        if (state == st_init)
        begin
            mult4ac_res_ready <= 0;
            multbb_res_ready <= 0;
            mult4ac_error_reg<=0;
            multbb_error_reg<=0;

        end
        else if (state == st_wait_muls)
        begin
            if (multac_down_valid && multac_error)
            begin
                mult4ac_error_reg <=1;
            end;
            if (mult4ac_down_valid)
            begin
                mult4ac_res_ready <= 1;
                mult4ac_res_reg <= mult4ac_res;
                mult4ac_error_reg <= mult4ac_error;
            end
            if (multbb_down_valid)
            begin
                multbb_res_ready <= 1;
                multbb_res_reg <= multbb_res;
                multbb_error_reg <= multbb_error;
            end            
        end

endmodule
