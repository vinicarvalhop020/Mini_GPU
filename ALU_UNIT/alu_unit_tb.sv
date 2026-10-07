`timescale 1ns / 1ps

module alu_unit_tb;

    localparam logic [3:0] ADD = 4'h1,
                           SUB = 4'h2,
                           MUL = 4'h3,
                           DIV = 4'h4;

    logic [7:0] a;
    logic [7:0] b;
    logic [3:0] alu_control;
    logic [7:0] result;
    logic       zero;

    alu_unit uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    task automatic test_alu(
        input logic [7:0]  a_in,
        input logic [7:0]  b_in,
        input logic [3:0]  control_in,
        input logic [7:0]  expected_result,
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
            assert (zero === (expected_result == 8'h00))
                else $fatal(1, "%s: flag zero incorreta", test_name);
        end
    endtask

    initial begin
        test_alu(8'd10, 8'd5, ADD, 8'd15, "ADD");
        test_alu(8'd10, 8'd5, SUB, 8'd5,  "SUB");
        test_alu(8'd10, 8'd5, MUL, 8'd50, "MUL");
        test_alu(8'd10, 8'd5, DIV, 8'd2,  "DIV");
        test_alu(8'hFF, 8'h01, ADD, 8'h00, "overflow de ADD");
        test_alu(8'h00, 8'h01, SUB, 8'hFF, "underflow de SUB");
        test_alu(8'hFF, 8'h02, MUL, 8'hFE, "truncamento de MUL");
        test_alu(8'h2A, 8'h00, DIV, 8'h00, "DIV por zero");
        test_alu(8'h12, 8'h34, 4'h0, 8'h00, "opcode invalido");

        $display("alu_unit_tb: todos os testes passaram.");
        $finish;
    end

endmodule
