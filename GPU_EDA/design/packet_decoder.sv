`timescale 1ns / 1ps

module packet_decoder (
    // Clk e reset
    input  logic clk, // Clock de armazenamento do pacote.
    input  logic rst, // Reset assincrono ativo em nivel alto.

    // Payload de comunicação com o host
    // TYPE | FIELD_0 | FIELD_1 | FIELD_2 | FIELD_3 | FIELD_4
    input  logic [41:0] req_payload, // {TYPE[1:0], FIELD_0, FIELD_1, FIELD_2, FIELD_3, FIELD_4}.

    // Handhsake com o host
    input  logic req_valid, // Host apresenta um novo pacote em req_payload.
    output logic req_ready, // Decoder esta livre para aceitar o pacote do host.

    // Handshake com o AXI
    output logic decoded_valid, // Pacote armazenado esta valido para o AXI Slave.
    input  logic decoded_ready, // AXI Slave consumiu os campos decodificados.

    // Campos decodificados do pacote
    output logic [1:0] req_type, // MEM_READ=00, MEM_WRITE=01, GPU_COMMAND=10, GPU_START=11.
    output logic [7:0] field_0,  // Endereco usado pelos pacotes de memoria.
    output logic [7:0] field_1,  // Dado lane 0 ou opcode em GPU_COMMAND.
    output logic [7:0] field_2,  // Dado lane 1 ou src_a em GPU_COMMAND.
    output logic [7:0] field_3,  // Dado lane 2 ou src_b em GPU_COMMAND.
    output logic [7:0] field_4   // Dado lane 3 ou dst em GPU_COMMAND.
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
