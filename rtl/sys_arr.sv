`timescale 1ps/1ps

/*

This module will handle the systolic array architecture
Will generate every processing element (multiply and accumulaye) in a 
2D fashion. Each input a and b will be stream of arrays in order to allow 
the systolic array to be reconfigurable for any MxM matrix

*/
module sys_arr #(
    parameter M = 3 // square matrix width
)(
    input logic CLK,
    input logic rst,
    input logic vld_in,
    input logic rdy_out,
    input logic [7:0] a [0:M-1],
    input logic [7:0] b [0:M-1],
    output logic [15:0] c [0:M-1][0:M-1],
    output vld_out,
    output rdy_in
);

// intermediate wire to pass a and b to next processing element
logic [7:0] a_wire [0:M-1];
logic [7:0] b_wire [0:M-1];

// enable using handshake signals
logic en;
assign en = vld_in && rdy_out;

// initialize counter for vld_out
localparam int COUNT_WIDTH = $clog2(2*M);
logic [COUNT_WIDTH:0] cycle_count; // cycle count of MxM matrix is diagonal count
logic vld_out_reg;

// counter regiester to track cycles
always_ff @(posedge CLK or posedge rst) begin
    if (rst) begin
        cycle_count <= 0;
        vld_out_reg <= 0;
    end else if (en) begin
        cycle_count <= cycle_count + 1;
        vld_out_reg <= (cycle_count == 2*M - 2); // valid out once done
    end else begin
        vld_out_reg <= 0;
    end
end

// set output handshake signals
assign vld_out = vld_out_reg;
assign rdy_in = (cycle_count < 2*M - 2);


// each processing element will be an instance of a multiply and accumulate module
genvar i, j;
generate
    for (i = 0; i < M; i = i + 1 ) begin
        for (j = 0; j < M ; j = j + 1 ) begin

            // edge case: C[0][0] (top left)
            if (i == 0 && j == 0) begin
                mat_acc mat_acc(
                .CLK(CLK),
                .rst(rst),
                .en(en),
                .a(a[0]),
                .b(b[0]),
                .c(c[0][0]),
                .a_out(a_wire[0]),
                .b_out(b_wire[0])
            );

            // edge case: first row
            else if (i == 0 && j > 0 && j < M) begin
                mat_acc mat_acc(
                .CLK(CLK),
                .rst(rst),
                .en(en),
                .a(a_wire[j]), // feed in intermediate a wire
                .b(b[0]), // b stream goes into top row
                .c(c[0][j]), // output the top row of C
                .a_out(a_wire[j+1]), // set a wire for next column iteration
                .b_out(b_wire[0]) // set b wire for next row iteration
            );
            end

            // edge case: first column
            else if (j == 0 && i > 0 && i < M) begin
                mat_acc mat_acc(
                .CLK(CLK),
                .rst(rst),
                .en(en),
                .a(a[0]), // feed in a
                .b(b_wire[i]), // feed intermediate b wire
                .c(c[i][0]), // set output for C
                .a_out(a_wire[0]), // set a wire for next column
                .b_out(b_wire[i+1]) // set b wire for next row
            );
            end

            // all other processing elemenets
            end else begin
                mat_acc mat_acc(
                .CLK(CLK),
                .rst(rst),
                .en(en),
                .a(a_wire[j]),
                .b(b_wire[i]),
                .c(c[i][j]),
                .a_out(a_wire[j+1]),
                .b_out(b_wire[i+1])
            );
            end
            end
            
    end
endgenerate
    
endmodule


