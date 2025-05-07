module tb_sys;

logic clk;


// Sys module here

localparam CLK_PERIOD = 10;
always begin
	#(CLK_PERIOD/2)
	clk <= ~clk;
end

initial begin
	clk = 0;
	$dumpfile("tb_fib.vcd");
	$dumpvars(0);
end

task sys_test(input byte a[3][3], input byte b[3][3], output byte c[3][3]);
	
endtask




endmodule
