`timescale 1ns / 1ps

module alu_unit (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [3:0] alu_control,
    output logic [7:0] result,
    output logic       zero
);

    localparam logic [3:0] ADD = 4'h1,
                           SUB = 4'h2,
                           MUL = 4'h3,
                           DIV = 4'h4;

    always_comb begin
        case (alu_control)
            ADD:     result = a + b;
            SUB:     result = a - b;
            MUL:     result = a * b;
            DIV:     result = (b == 8'h00) ? 8'h00 : a / b;
            default: result = 8'h00;
        endcase

        zero = (result == 8'h00);
    end

endmodule
