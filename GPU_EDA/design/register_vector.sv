`timescale 1ns / 1ps

module register_vector (
    input  logic        clk,         // Clock de captura dos registradores.
    input  logic        rst,         // Reset assincrono ativo em nivel alto.
    input  logic [31:0] mem_b_rdata, // Vetor retornado pela porta B da memoria.
    input  logic        load_a,      // Captura mem_b_rdata em vector_a.
    input  logic        load_b,      // Captura mem_b_rdata em vector_b.
    output logic [31:0] vector_a,    // Primeiro operando entregue a ALU SIMD.
    output logic [31:0] vector_b     // Segundo operando entregue a ALU SIMD.
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            vector_a <= 32'b0;
            vector_b <= 32'b0;
        end else begin
            if (load_a) vector_a <= mem_b_rdata;
            if (load_b) vector_b <= mem_b_rdata;
        end
    end

endmodule
