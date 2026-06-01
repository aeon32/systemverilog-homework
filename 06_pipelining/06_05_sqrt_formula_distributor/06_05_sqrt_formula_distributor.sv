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
    localparam module_latency = 50;
    localparam instances_num = module_latency;
    
    localparam distributor_index_width = $clog2(instances_num);
    logic [distributor_index_width - 1 : 0] worker_index;
    logic [distributor_index_width - 1 : 0] read_index;

    
    wire  arg_valids[0:instances_num - 1];

    logic  [31:0] a_reg [0:instances_num - 1];
    logic  [31:0] b_reg [0:instances_num - 1];
    logic  [31:0] c_reg [0:instances_num - 1];

    wire  [31:0] a_wire [0:instances_num - 1];
    wire  [31:0] b_wire [0:instances_num - 1];
    wire  [31:0] c_wire [0:instances_num - 1];

    wire  [31:0] res_wire [0:instances_num - 1];

    wire  res_wire_vld [0:instances_num - 1];


   
    generate
        genvar i;
        for (i = 0; i < instances_num; i++)
        begin
            if (formula == 1)
            begin
                if (impl == 1)
                begin
                    formula_1_impl_1_top formula_module_1_1
                    (
                        .rst(rst),
                        .clk(clk),
                        .arg_vld(arg_valids[i]),
                        .a(a_wire[i]),
                        .b(b_wire[i]),
                        .c(c_wire[i]),
                        .res(res_wire[i]),
                        .res_vld(res_wire_vld[i])
                    );
                end
                else if (impl == 2)
                begin
                    formula_1_impl_2_top formula_module_1_2
                    (
                        .rst(rst),
                        .clk(clk),
                        .arg_vld(arg_valids[i]),
                        .a(a_wire[i]),
                        .b(b_wire[i]),
                        .c(c_wire[i]),
                        .res(res_wire[i]),
                        .res_vld(res_wire_vld[i])
                    );
                    
                end
            end
            else if (formula == 2)
            begin
                    formula_2_top formula_module_2
                    (
                        .rst(rst),
                        .clk(clk),
                        .arg_vld(arg_valids[i]),
                        .a(a_wire[i]),
                        .b(b_wire[i]),
                        .c(c_wire[i]),
                        .res(res_wire[i]),
                        .res_vld(res_wire_vld[i])
                    );                
                
            end



            assign arg_valids[i] = arg_vld && (i == worker_index);

            assign a_wire[i] = arg_valids[i] ? a : a_reg[i];
            assign b_wire[i] = arg_valids[i] ? b : b_reg[i];
            assign c_wire[i] = arg_valids[i] ? c : c_reg[i];
        end

    endgenerate

    assign res = res_wire[read_index];
    assign res_vld = res_wire_vld[read_index];
    

    always_ff @ (posedge clk)
    if (rst)
    begin
        worker_index <= 0;
        read_index <= 0;
    end
    else begin
        if (arg_vld)
        begin
            a_reg[worker_index] <= a;
            b_reg[worker_index] <= b;
            c_reg[worker_index] <= c;

            worker_index<= worker_index == instances_num - 1 ? 0 : worker_index + 1;
        end

        if (res_vld)
        begin
            read_index<= read_index == instances_num - 1 ? 0 : read_index + 1;
        end
    end

endmodule : sqrt_formula_distributor
