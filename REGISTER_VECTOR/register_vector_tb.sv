`timescale 1ns / 1ps

module register_vector_tb;
    logic clk;
    logic rst;
    logic [31:0] mem_b_rdata;
    logic load_a;
    logic load_b;
    logic [31:0] vector_a;
    logic [31:0] vector_b;

    register_vector uut (
        .clk(clk),
        .rst(rst),
        .mem_b_rdata(mem_b_rdata),
        .load_a(load_a),
        .load_b(load_b),
        .vector_a(vector_a),
        .vector_b(vector_b)
    );

    task automatic test_register_vector(
        input logic [31:0] mem_b_rdata_in,
        input logic load_a_in,
        input logic load_b_in,
        input logic [31:0] expected_vector_a,
        input logic [31:0] expected_vector_b,
        input string test_name
    );
        begin
            mem_b_rdata = mem_b_rdata_in;
            load_a = load_a_in;
            load_b = load_b_in;
            #1;

            assert (vector_a === expected_vector_a)
                else $fatal(1, "%s: vector_a esperado=%0h, obtido=%0h",
                            test_name, expected_vector_a, vector_a);
            assert (vector_b === expected_vector_b)
                else $fatal(1, "%s: vector_b esperado=%0h, obtido=%0h",
                            test_name, expected_vector_b, vector_b);
        end
    endtask

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #10;
        rst = 0;
    end

    initial begin
        // Test 1: Load into vector_a
        test_register_vector(32'hA5A5A5A5, 1, 0, 32'hA5A5A5A5, 32'h0, "Load vector_a");

        // Test 2: Load into vector_b
        test_register_vector(32'h5A5A5A5A, 0, 1, 32'hA5A5A5A5, 32'h5A5A5A5A, "Load vector_b");

        // Test 3: Load into both vectors
        test_register_vector(32'hFFFFFFFF, 1, 1, 32'hFFFFFFFF, 32'hFFFFFFFF, "Load both vectors");

        $display("All tests passed.");
        $finish;
    end

endmodule
