`timescale 1ns / 1ps

module alu_simd_tb;

    localparam int LANES = 4;
    localparam logic [7:0] ADD = 8'h01,
                           SUB = 8'h02,
                           MUL = 8'h03,
                           DIV = 8'h04;

    logic [63:0] vector_a;
    logic [63:0] vector_b;
    logic [7:0]  alu_opcode;
    logic [63:0] result;

    alu_simd #(.LANES(LANES)) uut (
        .vector_a(vector_a),
        .vector_b(vector_b),
        .alu_opcode(alu_opcode),
        .result(result)
    );

    task automatic test_simd(
        input logic [63:0] a_in,
        input logic [63:0] b_in,
        input logic [7:0]  opcode_in,
        input logic [63:0] expected_result,
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
        test_simd(64'h00FF_0001_FFFF_0000, 64'h0001_0002_0001_0001,
                  ADD, 64'h0100_0003_0000_0001,
                  "ADD em quatro lanes de 16 bits");
        test_simd(64'h0001_0000_0004_0100, 64'h0002_0001_0001_0001,
                  SUB, 64'hFFFF_FFFF_0003_00FF,
                  "SUB com underflow em duas lanes");
        test_simd(64'h00FF_0002_0001_0000, 64'h00FF_0003_0002_0001,
                  MUL, 64'hFE01_0006_0002_0000,
                  "MUL 8 x 8 com resultado de 16 bits");
        test_simd(64'hFE01_0009_00FF_0012, 64'h00FF_0002_0003_0000,
                  DIV, 64'h00FF_0004_0055_0000,
                  "DIV com divisor zero em uma lane");
        test_simd(64'hFFFF_FFFF_FFFF_FFFF, 64'h0001_0002_0003_0004,
                  8'h00, 64'h0000_0000_0000_0000, "opcode invalido");

        $display("alu_simd_tb: todos os testes passaram.");
        $finish;
    end

endmodule
