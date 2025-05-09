`timescale 1ps/1ps

module sys_arr(
    input logic CLK,
    input logic rst,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] c
);

genvar i, j;
generate
    for (i = 0; i < M; i = i + 1 ) begin
        for (j = 0; j < M ; j = j + 1 ) begin
            mat_acc mat_acc(
                .CLK(CLK),
                .rst(rst),
                .vld_in(vld_in),
                .rdy_out(rdy_out),
                .a(a),
                .b(b),
                .c(c),
                .vld_out(vld_out),
                .rdy_in(rdy_in)
            )
        end 
    end
endgenerate
    
endmodule


