`timescale 1ps/1ps

module tb_sys;

logic CLK;
logic rst;
//logic [7:0] a[0:2];
//logic [7:0] b[0:2];
//logic [15:0] c[0:2][0:2];
logic [7:0] a;
logic [7:0] b;
logic [15:0] c;
logic miso;
logic mosi;
logic rdy_in;
logic vld_out;
logic rdy_out;
logic vld_in;
logic start;
logic spi_done;

/*spi_master spi (
    .rstb(~rst), // active low
    .clk(clk),
    .mlb(1'b1),
    .start(start),
    .tdat(c),
    .cdiv(2'b00),
    .din(miso),
    .ss(vld_in),
    .sck(sck),
    .dout(mosi),
    .done(spi_done),
    .rdata(a)
);*/

// Sys module here

main #(.M(3)) main_sys(
	.CLK(CLK),
	.rst(rst),
	.vld_in(vld_in),
	.rdy_out(rdy_out),
	.a(a),
	.b(b),
	.c(c),
	.rdy_in(rdy_in),
	.vld_out(vld_out)
	);


localparam CLK_PERIOD = 10;
always begin
	#(CLK_PERIOD/2)
	CLK <= ~CLK;
end

initial begin
	CLK = 0;
	$dumpfile("tb_sys.vcd");
	$dumpvars(0);
end

initial begin

	//Identity test
	byte a_in[0:2][0:2] = '{
		'{1, 0, 0},
		'{0, 1, 0},
		'{0, 0, 1}
	};

	byte b_in[0:2][0:2] = '{
		'{1, 0, 0},
		'{0, 1, 0},
		'{0, 0, 1}
	};

	shortint c_out[0:2][0:2];

	//sys_test(a_in, b_in, c_out);

	//General test
	a_in = '{
		'{1, 1, 0},
		'{0, 1, 0},
		'{0, 1, 1}
	};

	b_in = '{
		'{1, 0, 0},
		'{0, 2, 0},
		'{2, 0, 1}
	};

	sys_test(a_in, b_in, c_out);

	$finish();
end


// Task to test matmul
// NOTE: This performs a*b; the matrix b must be effectively transposed before
// feeding into systolic array
task sys_test(input byte a_in[0:2][0:2], input byte b_in[0:2][0:2], output shortint c_out[0:2][0:2]);
	rst = 1;
	vld_in = 1;
	wait(CLK);
	
	wait(~CLK);
	rst = 0;
	a = a_in[0][0];
	b = b_in[0][0];

	vld_in = 0;
	rdy_out = 1;
	wait(CLK);

	wait(~CLK);
	a = a_in[1][0];
	b = b_in[0][1];
	wait(CLK);

	wait(~CLK);
	a = a_in[2][0];
	b = b_in[0][2];
	wait(CLK);

	wait(~CLK);
	a = a_in[0][1];
	b = b_in[1][0];
	wait(CLK);

	wait(~CLK);
	a = a_in[1][1];
	b = b_in[1][1];
	wait(CLK);

	wait(~CLK);
	a = a_in[2][1];
	b = b_in[1][2];
	wait(CLK);

	wait(~CLK);
	a = a_in[0][2];
	b = b_in[2][0];
	wait(CLK);

	wait(~CLK);
	a = a_in[1][2];
	b = b_in[2][1];
	wait(CLK);

	wait(~CLK);
	a = a_in[2][2];
	b = b_in[2][2];
	wait(CLK);

	wait(~CLK);
	vld_in = 1;
	a = 0;
	b = 0;
	wait(vld_out);
	wait(~vld_out);
	wait(~CLK);
	wait(CLK);
endtask


endmodule
