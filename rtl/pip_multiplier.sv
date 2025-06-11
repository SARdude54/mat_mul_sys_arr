`timescale 1ps/1ps

module pip_multiplier (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    input  logic        valid_in,     
    output logic [15:0] product,
    output logic        valid_out
);

    // CLOCK 1
    logic [15:0] pp[0:7];
    genvar i;
    generate
        for (i = 0; i < 8; i++) begin
            always_ff @(posedge clk or posedge rst) begin
                if (rst)
                    pp[i] <= 16'd0;
                else
                    pp[i] <= (b[i]) ? ({8'd0, a} << i) : 16'd0;
            end
        end
    endgenerate

    // CLOCK 2
    logic [31:0] s1_0, s1_1, s1_2, s1_3;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_0 <= 0; s1_1 <= 0; s1_2 <= 0; s1_3 <= 0;
        end else begin
            s1_0 <= {16'd0, pp[0]} + {16'd0, pp[1]};
            s1_1 <= {16'd0, pp[2]} + {16'd0, pp[3]};
            s1_2 <= {16'd0, pp[4]} + {16'd0, pp[5]};
            s1_3 <= {16'd0, pp[6]} + {16'd0, pp[7]};
        end
    end

    // CLOCK 3
    logic [31:0] s2_0, s2_1;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            s2_0 <= 0; s2_1 <= 0;
        end else begin
            s2_0 <= s1_0 + s1_1;
            s2_1 <= s1_2 + s1_3;
        end
    end

    // CLOCK 4
    logic [31:0] sum;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            sum <= 0;
        else
            sum <= s2_0 + s2_1;
    end

    assign product = sum[15:0];

    // Valid pipeline shift register
    logic [3:0] valid_pipe;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            valid_pipe <= 4'b0000;
        else
            valid_pipe <= {valid_pipe[2:0], valid_in};
    end

    assign valid_out = valid_pipe[3]; // Delayed version of valid_in

endmodule
