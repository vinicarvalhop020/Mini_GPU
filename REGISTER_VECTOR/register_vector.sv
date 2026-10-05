`timescale 1ns / 1ps

module register_vector (
    input clk,
    input rst,
    input  logic [31:0] mem_b_rdata,
    input  load_a,
    input  load_b,
    output logic [31:0] vector_a,
    output logic [31:0] vector_b
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