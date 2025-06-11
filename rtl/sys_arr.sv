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
    input logic [(8*M-1):0] a,
    input logic [(8*M-1):0] b,
    output logic [(16*M*M-1):0] c,
    output vld_out,
    output rdy_in
);

logic [(8*M-1):0] int_a;
logic [(8*M-1):0] int_b;
logic [7:0] in_a_arr[0:(M-1)];
logic [7:0] in_b_arr[0:(M-1)];
logic [15:0] out_arr[0:(M-1)][0:(M-1)];

logic [(16*M*M-1):0] int_c;

always_comb
begin
    int_a = a;
    int_b = b;
    int_c = 0;
    for (int i = 0; i < M; i++)
    begin
        in_a_arr[M - i - 1] = int_a[7:0];
        int_a = int_a >> 8;
        in_b_arr[M - i - 1] = int_b[7:0];
        int_b = int_b >> 8;

        for (int j = 0; j < M; j++)
        begin
            int_c[15:0] = out_arr[i][j];
            if (i*M+j < M*M-1)
                int_c = int_c << 16;
        end
    end
    c = int_c;
end

// intermediate wire to pass a and b to next processing element
logic [7:0] a_wire [0:M-1][0:M-1];
logic [7:0] b_wire [0:M-1][0:M-1];

// enable using handshake signals
logic en;
assign en = vld_in && rdy_out;

// initialize counter for vld_out
localparam int COUNT_WIDTH = $clog2(2*M);
logic [COUNT_WIDTH:0] cycle_count; // cycle count of MxM matrix is diagonal count
logic vld_out_reg;

// counter regiester to track cycles
always_ff @(posedge CLK) begin
    if (rst) begin
        cycle_count <= 0;
        vld_out_reg <= 0;
    end else if (en) begin
        cycle_count <= cycle_count + 1;
        vld_out_reg <= (cycle_count == 2*M + 1); // valid out once done
    end else begin
        vld_out_reg <= 0;
    end
end

// set output handshake signals
assign vld_out = vld_out_reg;
assign rdy_in = (cycle_count < 2*M + 1);

// valid signals per processing element
logic valid_in_wire[0:M-1][0:M-1];
logic valid_out_wire[0:M-1][0:M-1];


// generate block that instantiates the mat_acc processing element
genvar i, j;
generate
    for (i = 0; i < M; i = i + 1 ) begin
        for (j = 0; j < M ; j = j + 1 ) begin

            logic local_valid;

            // edge case: C[0][0] (top left)
            if (i == 0 && j == 0) begin
                assign local_valid = vld_in;
                mat_acc mat_acc(
                    .CLK(CLK),
                    .rst(rst),
                    .en(en),
                    .valid_in(local_valid),
                    .valid_out(valid_out_wire[i][j]),
                    .a(in_a_arr[0]),
                    .b(in_b_arr[0]),
                    .c(out_arr[0][0]),
                    .a_out(a_wire[0][0]),
                    .b_out(b_wire[0][0])
                );
            end
            // edge case: first row
            else if (i == 0 && j > 0 && j < M) begin
                assign local_valid = valid_out_wire[i][j-1]; // note: using registered output!
                mat_acc mat_acc(
                    .CLK(CLK),
                    .rst(rst),
                    .en(en),
                    .valid_in(local_valid),
                    .valid_out(valid_out_wire[i][j]),
                    .a(a_wire[0][j-1]),
                    .b(in_b_arr[j]),
                    .c(out_arr[0][j]),
                    .a_out(a_wire[0][j]),
                    .b_out(b_wire[0][j])
                );
            end

            // edge case: first column
            else if (j == 0 && i > 0 && i < M) begin
                assign local_valid = valid_out_wire[i-1][j]; // use previous PE's valid_out
                mat_acc mat_acc(
                    .CLK(CLK),
                    .rst(rst),
                    .en(en),
                    .valid_in(local_valid),
                    .valid_out(valid_out_wire[i][j]),
                    .a(in_a_arr[i]),
                    .b(b_wire[i-1][0]),
                    .c(out_arr[i][0]),
                    .a_out(a_wire[i][0]),
                    .b_out(b_wire[i][0])
                );
            end

            // all other processing elemenets
            else begin
                assign local_valid = valid_out_wire[i-1][j-1]; // diagonally upstream
                mat_acc mat_acc(
                    .CLK(CLK),
                    .rst(rst),
                    .en(en),
                    .valid_in(local_valid),
                    .valid_out(valid_out_wire[i][j]),
                    .a(a_wire[i][j-1]),
                    .b(b_wire[i-1][j]),
                    .c(out_arr[i][j]),
                    .a_out(a_wire[i][j]),
                    .b_out(b_wire[i][j])
                );
            end
        end
    end
endgenerate



    
endmodule


