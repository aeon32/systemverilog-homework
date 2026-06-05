module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.

    localparam module_latency = 12;
    localparam instances_num = module_latency;
    
    localparam distributor_index_width = $clog2(instances_num);
    logic [distributor_index_width - 1 : 0] worker_index;
    logic [distributor_index_width - 1 : 0] read_index;

    
    wire  arg_valids[0:instances_num - 1];

    logic  [FLEN - 1:0] a_reg [0:instances_num - 1];
    logic  [FLEN - 1:0] b_reg [0:instances_num - 1];
    logic  [FLEN - 1:0] c_reg [0:instances_num - 1];

    wire  [FLEN - 1:0] a_wire [0:instances_num - 1];
    wire  [FLEN - 1:0] b_wire [0:instances_num - 1];
    wire  [FLEN - 1:0] c_wire [0:instances_num - 1];

    wire  [FLEN - 1:0] res_wire [0:instances_num - 1];

    wire  res_wire_vld [0:instances_num - 1];
    wire  err_wire [0:instances_num - 1];
    wire  res_wire_negative [0:instances_num - 1];

    generate
        genvar i;
        for (i = 0; i < instances_num; i++)
        begin
            float_discriminant discr
            (
                .rst(rst),
                .clk(clk),
                .arg_vld(arg_valids[i]),
                .a(a_wire[i]),
                .b(b_wire[i]),
                .c(c_wire[i]),
                .res(res_wire[i]),
                .res_vld(res_wire_vld[i]),
                .res_negative(res_wire_negative[i]),
                .err(err_wire[i])
            );
                

            assign arg_valids[i] = arg_vld && (i == worker_index);

            assign a_wire[i] = arg_valids[i] ? a : a_reg[i];
            assign b_wire[i] = arg_valids[i] ? b : b_reg[i];
            assign c_wire[i] = arg_valids[i] ? c : c_reg[i];
        end

    endgenerate

    assign res = res_wire[read_index];
    assign res_vld = res_wire_vld[read_index];
    assign res_negative = res_wire_negative[read_index];
    assign err = err_wire[read_index];
    

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


endmodule
