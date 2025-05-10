`timescale 1ps/1ps

// Main module including systolic array and two feeds
module main #(parameter M=3) (
	input CLK,
	input rst,
	input vld_in,
	input rdy_out,
	input logic [7:0] a[0:(M-1)],
	input logic [7:0] b[0:(M-1)],
	output logic [15:0] c[0:(M-1)][0:(M-1)],
	output logic rdy_in,
	output logic vld_out
	);
	
	logic [7:0] a_sys[0:(M-1)];
	logic [7:0] b_sys[0:(M-1)];

	feed #(.M(M)) a_feed(
		.CLK(CLK),
		.a_in(a),
		.a_out(a_sys)
		);

	feed #(.M(M)) b_feed(
		.CLK(CLK),
		.a_in(b),
		.a_out(b_sys)
		);

	sys_arr #(.M(M)) sys(
		.CLK(CLK),
		.rst(rst),
		.vld_in(vld_in),
		.rdy_out(rdy_out),
		.a(a_sys),
		.b(b_sys),
		.c(c),
		.rdy_in(rdy_in),
		.vld_out(vld_out)
		);	
	

endmodule
