`timescale 1ps/1ps

`define DEPTH 16
`define WIDTH 8

// Main module including systolic array and two feeds
module main #(parameter M=3) (
	input CLK,
	input rst,
	input vld_in,
	input rdy_out,
	//input [7:0] a[0:(M-1)],
	//input [7:0] b[0:(M-1)],
	//output logic [15:0] c[0:(M-1)][0:(M-1)],
	input [7:0] a,
	input [7:0] b,
	output logic [15:0] c,
	output logic rdy_in,
	output logic vld_out
	);
	
	logic [(8*M-1):0] a_sys;
	logic [(8*M-1):0] b_sys;
	logic [(16*M*M-1):0] sys_out;
	logic [(16*M*M-1):0] sys_out_int;

	logic [15:0] sys_out_arr[0:(M-1)][0:(M-1)];

	logic [(8*M-1):0] a_par;
	logic [(8*M-1):0] b_par;

	logic [7:0] a_in;
	logic [7:0] b_in;
	logic [7:0] sys_ser;

	logic sys_done;
	logic out_done;
	logic out_en;
	logic [$clog2(M)-1:0] row_count;
	logic [$clog2(M)-1:0] col_count;

	always_comb
	begin
		sys_out_int = sys_out;
		for (int i = 0; i < M; i++)
		begin
			for (int j = 0; j < M; j++)
			begin
				sys_out_arr[i][j] = sys_out_int[15:0];
				sys_out_int = sys_out_int >> 16;
			end
		end
	end

	always @(posedge CLK)
	begin

		if (sys_done)
			out_en <= 1;
		else
			out_en <= out_en;

		if (out_en)
		begin
			vld_out <= 1;
			c <= sys_out_arr[row_count][col_count];
			if (col_count == M-1)
			begin
				row_count <= row_count + 1;
				col_count <= 0;
			end
			else
			begin
				row_count <= row_count;
				col_count <= col_count + 1;
			end
			if ((row_count == M-1) && (col_count == M-1))
				out_en <= 0;
			else
				out_en <= out_en;
		end
		else
		begin
			vld_out <= 0;
			row_count <= 0;
			col_count <= 0;
			out_done <= 0;
			c <= 0;
		end
	end


	sp_buf #(.DEPTH(16), .WIDTH(8), .IN(1), .OUT(M)) a_buf (
		.a_in(a),
		.clk(CLK),
		.en_in(~vld_in),
		.en_out(vld_in),
		.a_out(a_par)
		);

	sp_buf #(.DEPTH(16), .WIDTH(8), .IN(1), .OUT(M)) b_buf (
		.a_in(b),
		.clk(CLK),
		.en_in(~vld_in),
		.en_out(vld_in),
		.a_out(b_par)
		);

	feed #(.M(M)) a_feed(
		.CLK(CLK),
		.a_in(a_par),
		.a_out(a_sys)
		);

	feed #(.M(M)) b_feed(
		.CLK(CLK),
		.a_in(b_par),
		.a_out(b_sys)
		);

	/*spi_slave spi (
		.rstb(~rst),
		.ten(1'b1),
		.ss(vld_in),
		.sck(CLK),
		.sdin(a),
		.mlb(1'b1),
		.tdata(sys_ser),
		.sdout(c),
		.done(spi_done),
		.rdata(a_in)
	);*/

	sys_arr #(.M(M)) sys(
		.CLK(CLK),
		.rst(rst),
		.vld_in(vld_in),
		.rdy_out(rdy_out),
		.a(a_sys),
		.b(b_sys),
		.c(sys_out),
		.rdy_in(rdy_in),
		.vld_out(sys_done)
		);	
	

endmodule
