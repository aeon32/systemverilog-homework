module my_fifo
# (
    parameter width = 16,
              size  = 4
)
(
    input         clk,
    input         rst,

    input         up_vld,
    input  [width - 1 : 0] up_data,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

endmodule

module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    localparam max_latency = 50;

    localparam queue_index_width = $clog2(max_latency);
    localparam input_index_width = $clog2(n_inputs);

    //index to read
    logic [input_index_width - 1 : 0] read_index;

    //input queue
    logic [width - 1 : 0] data_regs [ 0:input_index_width - 1];
    logic [n_inputs - 1 : 0 ] data_regs_valids;
    logic [n_inputs - 1 : 0 ] new_data_regs_valids;

    assign down_data = data_regs[read_index];
    assign down_vld = data_regs_valids[read_index];

        
    always_comb
    begin
       new_data_regs_valids = data_regs_valids;
       if (down_vld)
          new_data_regs_valids[read_index] = 0;
        new_data_regs_valids = new_data_regs_valids | up_vlds;

        for (int i = 0; i < n_inputs; i++)
        begin

          
        end
          

    end
   
     

    generate
        genvar i;
        for (i = 0; i < n_inputs; i++)
        begin
          
        end   
    endgenerate


    always_ff @ (posedge clk)
    if (rst)
    begin
        data_regs_valids <= 0;
        read_index <= 0;
    end
    else begin
       data_regs_valids <= new_data_regs_valids;
       if (down_vld)    
         read_index <= (read_index == (n_inputs - 1) ) ? 0 : read_index + 1;

       for (int i = 0; i < n_inputs; i++)
       begin
         if (up_vlds[i])
         begin
            data_regs[i] <= up_data[i]; 
         end   
       end  
    end

endmodule
