module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
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
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.
    localparam instances_num = 5;
    localparam module_latency = 50;
    
    localparam distributor_index_width = $clog2(instances_num);
    logic [distributor_index_width - 1 : 0] distributor_index;
    
    wire arg_valids [0:instances_num - 1];;
   
    generate
        genvar i;
        for (i = 0; i < instances_num; i++)
        begin
            formula_1_impl_1_top formula_module
            (
                .rst(rst),
                .clk(clk),
                .arg_vld(arg_valids[i])

            );
            

            if (formula == 1)
            begin : if_formula_1
        
            end    
        

        end

        

    endgenerate
    



    always_ff @ (posedge clk)
    if (rst)
        distributor_index <= '0;
    else begin
        if (arg_vld)
        begin
            distributor_index<= distributor_index == instances_num - 1 ? 0 : distributor_index + 1;
        end
    end

endmodule : sqrt_formula_distributor
