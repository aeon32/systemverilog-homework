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

    logic [FLEN - 1:0] mult_a, mult_b, mult_res;
    logic multbb_up_valid, multbb_down_valid, multbb_busy, multbb_error;

     f_mult mult_b_b (
        .clk (clk),
        .rst(rst),
        .a(a),
        .b(b),
        .up_valid(mult_up_valid),
        .down_valid(mult_down_valid),
        .busy(mult_busy),
        .error(mult_error)
    );

     enum logic [2:0]
    {
        st_idle       = 3'd0,
        st_wait_res = 3'd1
    } state, next_state;


    always_comb
    begin
        next_state  = state;
        mult_up_valid = 0;

        // This lint warning is bogus because we assign the default value above
        // verilator lint_off CASEINCOMPLETE

        case (state)
            st_idle:
            begin
                if (arg_vld)
                begin
                    multbb_up_valid = '1;
                end
            end

            st_wait_1_res:
            begin
                if (isqrt_1_y_vld)
                begin
                    isqrt_1_x = c_reg;
                    isqrt_1_x_vld = '1;
                    y1 = isqrt_1_y;
                    next_state  = st_wait_2_res;
                end
                if (isqrt_2_y_vld)
                begin
                    isqrt_2_x = c;
                    isqrt_2_x_vld = !isqrt_1_y_vld;
                    y2 = isqrt_2_y;
                    next_state  = st_wait_2_res;
                end
            end

            st_wait_2_res:
            begin
                if (isqrt_1_y_vld)
                begin
                    y1 = isqrt_1_y;
                end

                if (isqrt_2_y_vld)
                begin
                    y2 = isqrt_2_y;
                end
                if ((got + isqrt_1_y_vld + isqrt_2_y_vld) == 3)
                begin
                    next_state = st_idle;
                end


            end
        endcase




endmodule
