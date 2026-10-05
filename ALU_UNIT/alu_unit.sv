`timescale 1ns / 1ps

interface alu_unit_if;
    logic [7:0] a;
    logic [7:0] b;
    logic [3:0] alu_control;
    logic [7:0] result;
    logic zero;
endinterface

module alu_unit (
    alu_unit_if alu_if
);

    localparam logic [3:0] ADD = 4'h1,
                           SUB = 4'h2,
                           MUL = 4'h3,
                           DIV = 4'h4;

    always_comb begin
        case (alu_if.alu_control)
            ADD:     alu_if.result = alu_if.a + alu_if.b;
            SUB:     alu_if.result = alu_if.a - alu_if.b;
            MUL:     alu_if.result = alu_if.a * alu_if.b;
            DIV:     alu_if.result = (alu_if.b == 8'h00) ? 8'h00
                                                         : alu_if.a / alu_if.b;
            default: alu_if.result = 8'h00;
        endcase

        alu_if.zero = (alu_if.result == 8'h00);
    end

endmodule
