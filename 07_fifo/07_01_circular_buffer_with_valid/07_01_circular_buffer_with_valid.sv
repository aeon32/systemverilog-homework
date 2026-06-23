//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module one_bit_wide_circular_buffer
# (
    parameter depth = 8
)
(
    input  clk,
    input  rst,

    input  in_data,
    output out_data
);

    localparam pointer_width = $clog2 (depth);
    localparam [pointer_width - 1:0] max_ptr = pointer_width' (depth - 1);

    logic [pointer_width - 1:0] ptr;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            ptr <= '0;
        else
            ptr <= ( ptr == max_ptr ) ? '0 : ptr + 1'b1;

    //------------------------------------------------------------------------

    logic [depth - 1:0] data;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            data <= '0;
        else
            data [ptr] <= in_data;

    assign out_data = data [ptr];

endmodule

//----------------------------------------------------------------------------

module circular_buffer
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);

    localparam pointer_width = $clog2 (depth);
    localparam [pointer_width - 1:0] max_ptr = pointer_width' (depth - 1);

    logic [pointer_width - 1:0] ptr;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            ptr <= '0;
        else
            ptr <= ( ptr == max_ptr ) ? '0 : ptr + 1'b1;

    //------------------------------------------------------------------------

    logic [width - 1:0] data [0: depth - 1];

    always_ff @ (posedge clk)
        data [ptr] <= in_data;

    assign out_data  = data [ptr];

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module circular_buffer_with_valid_old
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input                in_valid,
    input  [width - 1:0] in_data,

    output               out_valid,
    output [width - 1:0] out_data
);

    // Task:
    // Implement a variant of a circular buffer module
    // with support for valid interface. A module should move
    // the pointer only in cases of valid data transfer.

    localparam pointer_width = $clog2 (depth);
    localparam [pointer_width - 1:0] max_ptr = pointer_width' (depth - 1);

    logic [pointer_width - 1:0] write_ptr;
    logic [pointer_width - 1:0] next_write_ptr;
    logic [pointer_width - 1:0] read_ptr;
    logic [pointer_width -1 :0] delay;
    
    
    logic out_valid_reg;
    logic [depth - 1 : 0] [width - 1:0] data ;

    logic [31:0] count;

    always_comb
    begin
       next_write_ptr = (write_ptr == max_ptr) ? 0 : write_ptr + 1'b1;

    end

 
    always_ff @ (posedge clk or posedge rst)
        if (rst) 
        begin            
            write_ptr <= 0;
            read_ptr <= 0;
            out_valid_reg <= 0;
            count <=0;
            delay <=0;
        end
        else
        begin 
            if (in_valid)
            begin
                write_ptr <= (write_ptr == max_ptr) ? 0 : write_ptr + 1'b1;;
                data [write_ptr] <= in_data;

                if (write_ptr == read_ptr)
                    delay <= depth - 1;

                count <= count + 1;
            end
              

            if (delay > 0)
            begin
                delay <= delay - 1;
            end
            else 
            begin
                if (write_ptr != read_ptr)
                   read_ptr <= (read_ptr == max_ptr) ? 0 : read_ptr + 1'b1;
            end               

        end

    //------------------------------------------------------------------------
    assign out_data  = data [read_ptr];
    assign out_valid = (delay == 0) && (write_ptr != read_ptr);

endmodule


module circular_buffer_with_valid
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input                rst,

    input                in_valid,
    input  [width - 1:0] in_data,

    output               out_valid,
    output [width - 1:0] out_data
);

    // Task:
    // Implement a variant of a circular buffer module
    // with support for valid interface. A module should move
    // the pointer only in cases of valid data transfer.

    localparam pointer_width = $clog2 (depth);
    localparam [pointer_width - 1:0] max_ptr = pointer_width' (depth - 1);

    logic [pointer_width - 1:0] write_ptr;
    
    
    logic [depth - 1 : 0] [width - 1:0] data ;
    logic [depth - 1 : 0] valids;




    always_ff @ (posedge clk or posedge rst)
        if (rst) 
        begin            
            write_ptr <= 0;
            valids <= 0;
        end
        else
        begin 
            write_ptr <= (write_ptr == max_ptr) ? 0 : write_ptr + 1'b1;;
            data [write_ptr] <= in_data;
            valids[write_ptr] <= in_valid;
        end

    //------------------------------------------------------------------------
    assign out_data  = data [write_ptr];
    assign out_valid =  valids[write_ptr];

endmodule