`timescale 1ps/1ps


/* This processing element is a multiply and accumulate. 
   Each processing element must pass a and b as an ouput in order
   to feed to neighboring multiply and accumulate modules

*/
module mat_acc(
    input logic CLK,
    input logic rst,
    input logic en,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [15:0] c,
    output logic [7:0] a_out,
    output logic [7:0] b_out
);

// register for matrix output element c[i][j]
logic [15:0] cij; 

// mult and acc register
always_ff @(posedge CLK) begin
    if (rst) begin
        cij <= 0;
    end else if (en) begin
        cij <= cij + a * b;
    end   
    a_out <= a;
    b_out <= b;
end

// assign outputs
assign c = cij;
    
endmodule


