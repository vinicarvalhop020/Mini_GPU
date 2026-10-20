`timescale 1ns / 1ps

module alu_unit_tb;

    localparam logic [3:0] ADD = 4'h1,
                           SUB = 4'h2,
                           MUL = 4'h3,
                           DIV = 4'h4;

    logic [15:0] a;
    logic [15:0] b;
    logic [3:0] alu_control;
    logic [15:0] result;
    logic       zero;
    logic       error;

    alu_unit uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero),
        .error(error)
    );

    task automatic test_alu(
        input logic [15:0] a_in,
        input logic [15:0] b_in,
        input logic [3:0]  control_in,
        input logic [15:0] expected_result,
        input logic        expected_error,
        input string       test_name
    );
        begin
            a           = a_in;
            b           = b_in;
            alu_control = control_in;
            #1;

            assert (result === expected_result)
                else $fatal(1, "%s: resultado esperado=%0h, obtido=%0h",
                            test_name, expected_result, result);
            assert (zero === (expected_result == 16'h0000))
                else $fatal(1, "%s: flag zero incorreta", test_name);
            assert (error === expected_error)
                else $fatal(1, "%s: erro esperado=%0b, obtido=%0b",
                            test_name, expected_error, error);
        end
    endtask

    initial begin
        test_alu(16'd10, 16'd5, ADD, 16'd15, 1'b0, "ADD");
        test_alu(-16'sd10, 16'd5, SUB, -16'sd15, 1'b0, "SUB signed");
        test_alu(16'hFF80, 16'hFF80, MUL, 16'h4000, 1'b0,
                 "MUL -128 x -128 preservado em 16 bits");
        test_alu(-16'sd10, 16'd5, DIV, -16'sd2, 1'b0, "DIV signed");
        test_alu(16'h7FFF, 16'h0001, ADD, 16'h8000, 1'b1, "overflow de ADD");
        test_alu(16'h8000, 16'h0001, SUB, 16'h7FFF, 1'b1, "overflow de SUB");
        test_alu(16'h002A, 16'h0000, DIV, 16'h0000, 1'b1, "DIV por zero");
        test_alu(16'h0012, 16'h0034, 4'h0, 16'h0000, 1'b0, "opcode invalido");

        $display("alu_unit_tb: todos os testes passaram.");
        $finish;
    end

endmodule
