//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.
    enum logic [2:0]
    {
        idle= 3'd0,
        sta_le_c = 3'd1,
        stb_le_c = 3'd2
    }
    state, next_state;
    
    logic [FLEN - 1 : 0] a, b, c;

    logic a_le_b, a_le_c, b_le_c;

    always_comb
    begin
        next_state  = state;
        valid_out = 0;

        // This lint warning is bogus because we assign the default value above
        // verilator lint_off CASEINCOMPLETE

        case (state)
            idle:
            begin
                if (valid_in)
                begin
                    f_le_a = unsorted[0];
                    f_le_b = unsorted[1];
                    if (f_le_err)
                    begin
                        next_state = idle;
                        valid_out = 1;                        
                    end                    
                    else
                        next_state = sta_le_c;
                end
            end
            sta_le_c:
            begin
                f_le_a = a;
                f_le_b = c;
                if (f_le_err)
                begin
                    next_state = idle;
                    valid_out = 1;  
                end
                else
                    next_state = stb_le_c;
            end
            stb_le_c:
            begin
                f_le_a = b;
                f_le_b = c;
                next_state = idle;
                valid_out = 1;
            end
        endcase
    end

    assign busy = ! (state == idle && next_state == idle);
    assign err = f_le_err;

    always_comb
    case ({a_le_b, f_le_res, a_le_c})
        3'b000: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[2], unsorted[1], unsorted[0] }; //a0 >= a1, a1 >= a2, a0 >= a2
        3'b001: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[2], unsorted[1], unsorted[0] }; //a0 >= a1, a1 >= a2, a0 <= a2
        
        3'b010: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[1], unsorted[2], unsorted[0] }; // a0 >= a1, a1 <= a2, a0 >= a2
        3'b011: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[1], unsorted[0], unsorted[2] }; // a0 >= a1, a1 <= a2, a0 <= a2 

        3'b100: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[2], unsorted[0], unsorted[1] }; //a0 <= a1, a1 >= a2, a0 >= a2
        3'b101: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[0], unsorted[2], unsorted[1] }; //a0 <= a1, a1 >= a2, a0 <= a2
        3'b110: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[0], unsorted[1], unsorted[2] }; //a0 <= a1, a1 <= a2, a0 >= a2
        3'b111: {sorted [0],  sorted [1],  sorted [2] } = { unsorted[0], unsorted[1], unsorted[2] }; //a0 <= a1, a1 <= a2, a0 <= a2
    endcase

   

    always_ff @ (posedge clk)
        if (rst)
        begin
            state <= idle;
        end
        else
            state <= next_state;
            
    always_ff @ (posedge clk)
        if (state == idle)
        begin
            if (valid_in)
            begin
                a <= unsorted[0];
                b <= unsorted[1];
                c <= unsorted[2];
                a_le_b <= f_le_res;
            end
        end
        else if (state == sta_le_c)
        begin
            a_le_c <= f_le_res;
        end

endmodule
