`timescale 1ps/1ps

module tb_pip_mult();

    // Inputs
    logic clk = 0;
    logic rst = 1;
    logic [7:0] a;
    logic [7:0] b;
    logic valid_in = 1;

    // Outputs
    logic [15:0] product;
    logic valid_out;

    // Internal queue to track expected outputs
    int unsigned expected_queue[$];
    int unsigned expected; // expected product
    bit expected_valid[$];  // New queue for tracking valid outputs
    bit should_check;


    // Instantiate DUT
    pip_multiplier dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .valid_in(valid_in),
        .product(product),
        .valid_out(valid_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting Pipelined Multiplier Test...");
        $dumpfile("tb_sys.vcd");
        $dumpvars(0);

        // Initialization
        a = 0;
        b = 0;

        // Apply reset for a few cycles
        repeat (3) @(posedge clk);
        rst = 0;

        // Apply test vectors
        @(posedge clk); a = 8'd13;  b = 8'd7;   valid_in = 1; expected_queue.push_back(13 * 7); expected_valid.push_back(1);
        @(posedge clk); a = 8'd255; b = 8'd255; valid_in = 1; expected_queue.push_back(255 * 255); expected_valid.push_back(1);
        @(posedge clk); a = 8'd0;   b = 8'd123; valid_in = 1; expected_queue.push_back(0); expected_valid.push_back(1);
        @(posedge clk); a = 8'd128; b = 8'd2;   valid_in = 1; expected_queue.push_back(128 * 2); expected_valid.push_back(1);

        // Insert bubbles (no valid input)
        repeat (4) begin
            @(posedge clk);
            a = 0;
            b = 0;
            valid_in = 0;
            expected_valid.push_back(0); // Add bubble tracking
        end


    forever begin
    @(posedge clk);
    
    if (expected_valid.size() == 0) begin
        $display("All tests passed.");
        $finish;
    end

    should_check = expected_valid.pop_front(); // Pop every cycle

    if (valid_out && should_check) begin
        expected = expected_queue.pop_front();
        $display("Cycle %0t: product = %0d (Expected = %0d)", $time, product, expected);
        assert(32'(product) == 32'(expected))
            else $error("Mismatch at time %0t: got %0d, expected %0d", $time, product, expected);
    end
end

end


endmodule