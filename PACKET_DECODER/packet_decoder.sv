`timescale 1ns / 1ps

module packet_decoder (
    // Clk e reset
    input  logic clk,
    input  logic rst,

    // Payload de comunicação com o host
    // TYPE | FIELD_0 | FIELD_1 | FIELD_2 | FIELD_3 | FIELD_4
    input  logic [41:0] req_payload,

    // Handhsake com o host
    input  logic req_valid,
    output logic req_ready,

    // Handshake com o AXI
    output logic decoded_valid,
    input  logic decoded_ready,

    // Campos decodificados do pacote
    output logic [1:0] req_type,
    output logic [7:0] field_0,
    output logic [7:0] field_1,
    output logic [7:0] field_2,
    output logic [7:0] field_3,
    output logic [7:0] field_4
);

    logic [41:0] packet_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            packet_reg    <= 42'b0;
            decoded_valid <= 1'b0;
        end else if (req_valid && req_ready) begin
            packet_reg    <= req_payload;
            decoded_valid <= 1'b1;
        end else if (decoded_valid && decoded_ready) begin
            decoded_valid <= 1'b0;
        end
    end

    always_comb begin
        req_ready = !decoded_valid;
        req_type  = packet_reg[41:40];
        field_0   = packet_reg[39:32];
        field_1   = packet_reg[31:24];
        field_2   = packet_reg[23:16];
        field_3   = packet_reg[15:8];
        field_4   = packet_reg[7:0];
    end

endmodule
