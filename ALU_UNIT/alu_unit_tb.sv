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

    alu_unit uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    task automatic test_alu(
        input logic [15:0] a_in,
        input logic [15:0] b_in,
        input logic [3:0]  control_in,
        input logic [15:0] expected_result,
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
        end
    endtask

    initial begin
        test_alu(16'd10, 16'd5, ADD, 16'd15, "ADD");
        test_alu(16'd10, 16'd5, SUB, 16'd5,  "SUB");
        test_alu(16'h00FF, 16'h00FF, MUL, 16'hFE01,
                 "MUL 8 x 8 preservado em 16 bits");
        test_alu(16'd10, 16'd5, DIV, 16'd2,  "DIV");
        test_alu(16'hFFFF, 16'h0001, ADD, 16'h0000, "overflow de ADD");
        test_alu(16'h0000, 16'h0001, SUB, 16'hFFFF, "underflow de SUB");
        test_alu(16'h002A, 16'h0000, DIV, 16'h0000, "DIV por zero");
        test_alu(16'h0012, 16'h0034, 4'h0, 16'h0000, "opcode invalido");

        $display("alu_unit_tb: todos os testes passaram.");
        $finish;
    end

endmodule
