`timescale 1ps/1ps

// Simple register implementation
// Out becomes in every clock cycle
module delay (
	input CLK,
	input [7:0] a_in,
	output logic [7:0] a_out
	);
	
	always @(posedge CLK)
		a_out <= a_in;
	
endmodule

// Module to feed values into systolic array
// Every nth row and nth col needs n delay blocks
// (n starts at 0)
module feed #(parameter M=3) (
	input CLK,
	input logic [(8*M-1):0] a_in,
	output logic [(8*M-1):0] a_out
	);

	logic [(8*M-1):0] int_in;
	//logic [(8*M-1):0] int_out;
	logic [7:0] in_arr[0:(M-1)];
	logic [7:0] out_arr[0:(M-1)];

	//assign a_out = int_out;
	logic [(8*M-1):0] int_out;

	always_comb
	begin
		int_in = a_in;
		//int_out = 0;
		int_out = 0;
		for (int i = 0; i < M; i++)
		begin
			in_arr[M - i - 1] = int_in[7:0];
			int_in = int_in >> 8;

			int_out[7:0] = out_arr[i];
			if (i < (M-1))
				int_out = int_out << 8;
		end
		a_out = int_out;
	end

	
	// Generate delay blocks here
	genvar i, j;
	generate
		//int_in = a_in;
		for (i = 0; i < M; i++)
		begin
			// Connections between delay blocks
			logic [7:0] conn[0:i];

			// Assign input and outputs of feed module
			assign conn[0] = in_arr[i];
			//a_in = a_in >> 8;
			assign out_arr[i] = conn[i];
			//a_out = a_out << 8;

			for (j = 0; j < i; j++)
			begin
				delay d(
					.CLK(CLK),
					.a_in(conn[j]),
					.a_out(conn[j + 1])
					);		
			end
		
		end

	endgenerate

endmodule
