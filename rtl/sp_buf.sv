`timescale 1ps/1ps

module sp_buf #(parameter DEPTH=2, parameter WIDTH=2, parameter IN=2, parameter OUT=2) (
    input [(WIDTH-1):0] a_in,
    input clk,
    input en_in,
    input en_out,
    output logic [(WIDTH*OUT-1):0] a_out
    );

    logic [(WIDTH-1):0] buffer[0:(DEPTH-1)];
    logic [$clog2(DEPTH):0] w_ptr;
    logic [$clog2(DEPTH):0] r_ptr;

    logic full;
    assign full = (w_ptr[$clog2(DEPTH)] != r_ptr[$clog2(DEPTH)]) && (w_ptr[$clog2(DEPTH)-1:0] == r_ptr[$clog2(DEPTH)-1:0]);
    logic empty;
    assign empty = w_ptr <= r_ptr;

    initial
    begin
        w_ptr = 0;
        r_ptr = 0;
    end

    always @(posedge clk)
    begin
        if (en_in && !full)
        begin
            buffer[w_ptr[$clog2(DEPTH)-1:0]] <= a_in;
            w_ptr <= (w_ptr + 1) % DEPTH;
        end
        else
        begin
            buffer[w_ptr[$clog2(DEPTH)-1:0]] <= buffer[w_ptr[$clog2(DEPTH)-1:0]];
            w_ptr <= w_ptr;
        end

        if (en_out && !empty)
        begin
            byte i;
            logic [(WIDTH*OUT-1):0] int_out;
            for (i = 0; i < OUT; i++)
            begin
                int_out[(WIDTH-1):0] = buffer[(r_ptr[$clog2(DEPTH)-1:0] + i[$clog2(DEPTH)-1:0]) % DEPTH];
                if (i < (OUT - 1))
                    int_out = int_out << WIDTH;
            end
            a_out <= int_out;
            if ((r_ptr + OUT) % DEPTH > w_ptr)
                r_ptr <= w_ptr;
            else
                r_ptr <= (r_ptr + OUT) % DEPTH;
        end
        else
        begin
            a_out <= 0;
            r_ptr <= r_ptr;
        end
            

    end


endmodule