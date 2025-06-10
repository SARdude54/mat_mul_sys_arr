`timescale 1ps/1ps

module pip_multiplier (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);

    // CLOCK 1
    // Generate partial products
    logic [15:0] pp[0:7];
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            always_ff @(posedge clk or posedge rst) begin
                if (rst)
                    pp[i] <= 16'd0;
                else
                    // shift a by i if b = 1
                    // else, product is zero
                    pp[i] <= (b[i]) ? ({8'd0, a} << i) : 16'd0;
                    // this will result in 8 shifted copied of a such that it will align
                    // with bit positions of b
            end
        end
    endgenerate

    // CLOCK 2
    // Pairwise addition of partial products
    logic [31:0] s1_0, s1_1, s1_2, s1_3;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_0 <= 0; s1_1 <= 0; s1_2 <= 0; s1_3 <= 0;
        end else begin
            // reduce partial products to 4 sums
            s1_0 <= {16'd0, pp[0]} + {16'd0, pp[1]};
            s1_1 <= {16'd0, pp[2]} + {16'd0, pp[3]};
            s1_2 <= {16'd0, pp[4]} + {16'd0, pp[5]};
            s1_3 <= {16'd0, pp[6]} + {16'd0, pp[7]};
        end
    end

    // CLOCK 3
    // Second layer of reduction
    logic [31:0] s2_0, s2_1;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            s2_0 <= 0; s2_1 <= 0;
        end else begin
            // reduce the 4 sums to 2 sums
            s2_0 <= s1_0 + s1_1;
            s2_1 <= s1_2 + s1_3;
        end
    end

    // CLOCK 4
    // final addition
    logic [31:0] sum;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            sum <= 0;
        else
            // add the final 2 sums
            sum <= s2_0 + s2_1;
    end

    assign product = sum[15:0]; // Truncate to 16 bits

endmodule