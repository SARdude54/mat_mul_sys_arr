`timescale 1ps/1ps

module mat_acc(
    input logic CLK,
    input logic rst,
    input logic vld_in,
    input logic rdy_out,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [7:0] c,
    output vld_out,
    output rdy_in
);

logic [7:0] cij;


always_ff @(posedge CLK) begin : blockName
    if (rst) begin
        cij <= 0;
    end else begin
        cij <= cij + a * b;
    end   
end

assign c = cij;
    
endmodule


