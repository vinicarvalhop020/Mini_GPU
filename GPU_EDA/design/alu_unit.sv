`timescale 1ns / 1ps

module alu_unit (
    input  logic signed [15:0] a,   // Operando A signed de uma lane SIMD.
    input  logic signed [15:0] b,   // Operando B signed de uma lane SIMD.
    input  logic [3:0] alu_control, // Operacao ADD=1, SUB=2, MUL=3, DIV=4.
    output logic signed [15:0] result, // Resultado signed da operacao.
    output logic       zero,        // Ativo quando result e igual a zero.
    output logic       error        // Overflow signed ou divisao por zero.
);

    localparam logic [3:0] ADD = 4'h1,
                           SUB = 4'h2,
                           MUL = 4'h3,
                           DIV = 4'h4;

    logic signed [31:0] product_full;

    always_comb begin
        result       = 16'sd0;
        error        = 1'b0;
        product_full = 32'sd0;

        case (alu_control)
            ADD: begin
                result = a + b;
                error  = (a[15] == b[15]) && (result[15] != a[15]);
            end
            SUB: begin
                result = a - b;
                error  = (a[15] != b[15]) && (result[15] != a[15]);
            end
            MUL: begin
                product_full = $signed({{16{a[15]}}, a}) *
                               $signed({{16{b[15]}}, b});
                result = product_full[15:0];
                error  = (product_full > 32'sd32767) ||
                         (product_full < -32'sd32768);
            end
            DIV: begin
                if (b == 16'sd0) begin
                    result = 16'sd0;
                    error  = 1'b1;
                end else begin
                    result = a / b;
                    error  = (a == 16'sh8000) && (b == -16'sd1);
                end
            end
            default: begin
                result = 16'sd0;
            end
        endcase

        zero = (result == 16'sd0);
    end

endmodule
