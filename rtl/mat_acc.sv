`timescale 1ps/1ps

/*
  This processing element performs multiply and accumulate.
  It propagates inputs a and b to the neighboring elements,
  and accumulates the product into cij when valid_in is asserted.
*/
module mat_acc(
    input  logic        CLK,
    input  logic        rst,
    input  logic        en,         // enable for accumulation
    input  logic        valid_in,   // valid input for pipelined multiplier
    output logic        valid_out,  // valid output for multiplier delayed by 4 cycles
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] c,
    output logic [7:0]  a_out,
    output logic [7:0]  b_out
);

    // Internal signals
    logic [15:0] product;
    logic [15:0] cij;

    // Pipelined multiplier
    pip_multiplier u_mult (
        .clk(CLK),
        .rst(rst),
        .a(a),
        .b(b),
        .valid_in(valid_in),
        .valid_out(valid_out),
        .product(product)
    );

    // Accumulator that add product when valid_out is high
    always_ff @(posedge CLK or posedge rst) begin
        if (rst) begin
            cij <= 0;
        end else if (en && valid_out) begin
            cij <= cij + product;
        end
    end

    // Send a and b to next elements
    always_ff @(posedge CLK or posedge rst) begin
        if (rst) begin
            a_out <= 0;
            b_out <= 0;
        end else if (en) begin
            a_out <= a;
            b_out <= b;
        end
    end

    assign c = cij;

endmodule
