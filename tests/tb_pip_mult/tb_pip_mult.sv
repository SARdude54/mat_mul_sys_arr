`timescale 1ps/1ps

module tb_pip_mult();

    // Inputs
    logic clk = 0;
    logic rst = 1;
    logic [7:0] a;
    logic [7:0] b;

    // Output
    logic [15:0] product;

    // Internal queue to track expected outputs
    int unsigned expected_queue[$];
    integer expected; // expected product

    // Instantiate DUT
    pip_multiplier dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .product(product)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting Pipelined Wallace Multiplier Test...");

        // Initialize
        a = 0;
        b = 0;

        // Apply reset for a few cycles
        repeat (3) @(posedge clk);
        rst = 0;

        // Test 1
        @(posedge clk);
        a = 8'd13;
        b = 8'd7;
        expected_queue.push_back(13 * 7);

        // Test 2
        @(posedge clk);
        a = 8'd255;
        b = 8'd255;
        expected_queue.push_back(255 * 255);

        // Test 3
        @(posedge clk);
        a = 8'd0;
        b = 8'd123;
        expected_queue.push_back(0);

        // Test 4
        @(posedge clk);
        a = 8'd128;
        b = 8'd2;
        expected_queue.push_back(128 * 2);

        // Insert bubbles after all test vectors
        repeat (4) begin
            @(posedge clk);
            a = 0;
            b = 0;
        end

        // Insert dummy cycles before checking to match 5-cycle latency
        repeat (5) expected_queue.push_front(0);

        // check each value in queue to RTL product
        for (int i = 0; i < expected_queue.size(); i++) begin
            @(posedge clk);
            expected = expected_queue.pop_front();
            $display("Cycle %0t: product = %0d (Expected = %0d)", $time, product, expected);
            assert(32'(product) == 32'(expected))
                else $error("Mismatch: got %0d, expected %0d", product, expected);

        end

        $display("All tests passed.");
        $finish;
    end

endmodule
