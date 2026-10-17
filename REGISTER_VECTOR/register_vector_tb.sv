`timescale 1ns / 1ps

module register_vector_tb;

    logic        clk;
    logic        rst;
    logic [63:0] mem_b_rdata;
    logic        load_a;
    logic        load_b;
    logic [63:0] vector_a;
    logic [63:0] vector_b;

    register_vector uut (
        .clk(clk), .rst(rst), .mem_b_rdata(mem_b_rdata),
        .load_a(load_a), .load_b(load_b),
        .vector_a(vector_a), .vector_b(vector_b)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic test_register_vector(
        input logic [63:0] data_in,
        input logic        load_a_in,
        input logic        load_b_in,
        input logic [63:0] expected_vector_a,
        input logic [63:0] expected_vector_b,
        input string       test_name
    );
        begin
            @(negedge clk);
            mem_b_rdata = data_in;
            load_a      = load_a_in;
            load_b      = load_b_in;
            @(posedge clk);
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
        rst = 1'b1;
        mem_b_rdata = '0;
        load_a = 1'b0;
        load_b = 1'b0;
        #1;
        assert (vector_a === 64'h0 && vector_b === 64'h0)
            else $fatal(1, "reset nao limpou os registradores");

        @(negedge clk);
        rst = 1'b0;

        test_register_vector(64'hA5A5_A5A5_1234_5678, 1'b1, 1'b0,
                             64'hA5A5_A5A5_1234_5678, 64'h0,
                             "load vector_a");
        test_register_vector(64'h5A5A_5A5A_8765_4321, 1'b0, 1'b1,
                             64'hA5A5_A5A5_1234_5678,
                             64'h5A5A_5A5A_8765_4321, "load vector_b");
        test_register_vector(64'hFFFF_0000_AAAA_5555, 1'b1, 1'b1,
                             64'hFFFF_0000_AAAA_5555,
                             64'hFFFF_0000_AAAA_5555, "load ambos");
        test_register_vector(64'h1234_5678_9ABC_DEF0, 1'b0, 1'b0,
                             64'hFFFF_0000_AAAA_5555,
                             64'hFFFF_0000_AAAA_5555, "hold sem load");

        $display("register_vector_tb: todos os testes passaram.");
        $finish;
    end

endmodule
