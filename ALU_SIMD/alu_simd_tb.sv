`timescale 1ns / 1ps

module alu_simd_tb;

    localparam int LANES = 4;
    localparam logic [7:0] ADD = 8'h01,
                           SUB = 8'h02,
                           MUL = 8'h03,
                           DIV = 8'h04;

    logic [31:0] vector_a;
    logic [31:0] vector_b;
    logic [7:0]  alu_opcode;
    logic [31:0] result;

    alu_simd #(.LANES(LANES)) uut (
        .vector_a(vector_a),
        .vector_b(vector_b),
        .alu_opcode(alu_opcode),
        .result(result)
    );

    task automatic test_simd(
        input logic [31:0] a_in,
        input logic [31:0] b_in,
        input logic [7:0]  opcode_in,
        input logic [31:0] expected_result,
        input string       test_name
    );
        begin
            vector_a   = a_in;
            vector_b   = b_in;
            alu_opcode = opcode_in;
            #1;

            assert (result === expected_result)
                else $fatal(1, "%s: resultado esperado=%0h, obtido=%0h",
                            test_name, expected_result, result);
        end
    endtask

    initial begin
        test_simd(32'hFA01_10FF, 32'h0702_F001, ADD, 32'h0103_0000,
                  "ADD com overflow em duas lanes");
        test_simd(32'h1000_04FF, 32'h0301_1001, SUB, 32'h0DFF_F4FE,
                  "SUB com underflow");
        test_simd(32'h1002_FF08, 32'h1080_0220, MUL, 32'h0000_FE00,
                  "MUL com truncamento");
        test_simd(32'h6409_FF12, 32'h0402_0003, DIV, 32'h1904_0006,
                  "DIV com divisor zero em uma lane");
        test_simd(32'hFFFF_FFFF, 32'h0102_0304, 8'h00, 32'h0000_0000,
                  "opcode invalido");

        $display("alu_simd_tb: todos os testes passaram.");
        $finish;
    end

endmodule
