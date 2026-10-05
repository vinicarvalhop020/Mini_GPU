`timescale 1ns / 1ps

module alu_unit_tb;

    localparam logic [3:0] ADD = 4'h1,
                           SUB = 4'h2,
                           MUL = 4'h3,
                           DIV = 4'h4;

    alu_unit_if alu_if();

    alu_unit uut (
        .alu_if(alu_if)
    );

    task automatic test_alu(
        input logic [7:0]  a,
        input logic [7:0]  b,
        input logic [3:0]  alu_control,
        input logic [7:0]  expected_result,
        input string       test_name
    );
        begin
            alu_if.a           = a;
            alu_if.b           = b;
            alu_if.alu_control = alu_control;
            #1;

            assert (alu_if.result === expected_result)
                else $fatal(1, "%s: resultado esperado=%0h, obtido=%0h",
                            test_name, expected_result, alu_if.result);

            assert (alu_if.zero === (expected_result == 8'h00))
                else $fatal(1, "%s: flag zero incorreta", test_name);
        end
    endtask

    initial begin
        test_alu(8'd10, 8'd5, ADD, 8'd15, "ADD");
        test_alu(8'd10, 8'd5, SUB, 8'd5,  "SUB");
        test_alu(8'd10, 8'd5, MUL, 8'd50, "MUL");
        test_alu(8'd10, 8'd5, DIV, 8'd2,  "DIV");

        // Casos de borda definidos na especificacao.
        test_alu(8'hFF, 8'h01, ADD, 8'h00, "overflow de ADD");
        test_alu(8'h00, 8'h01, SUB, 8'hFF, "underflow de SUB");
        test_alu(8'hFF, 8'h02, MUL, 8'hFE, "truncamento de MUL");
        test_alu(8'h2A, 8'h00, DIV, 8'h00, "DIV por zero");
        test_alu(8'h12, 8'h34, 4'h0, 8'h00, "opcode invalido");

        $display("alu_unit_tb: todos os testes passaram.");
        $finish;
    end

endmodule
