`include "uvm_macros.svh"
import uvm_pkg::*;

// Tipos definidos pelo protocolo de pacotes da GPU.
typedef enum logic [1:0] {
    GPU_MEM_READ    = 2'b00,
    GPU_MEM_WRITE   = 2'b01,
    GPU_COMMAND     = 2'b10,
    GPU_START       = 2'b11
} gpu_packet_type_e;

// Uma transacao representa uma requisicao do host e sua resposta associada.
class gpu_item extends uvm_sequence_item;
    `uvm_object_utils(gpu_item)

    // Campos de requisicao. Juntos formam req_payload[41:0].
    rand gpu_packet_type_e packet_type;
    rand logic [7:0]       field_0;
    rand logic [7:0]       field_1;
    rand logic [7:0]       field_2;
    rand logic [7:0]       field_3;
    rand logic [7:0]       field_4;

    // Campos preenchidos apos a resposta ser observada pelo driver ou monitor.
    logic [31:0] rsp_data;
    logic        rsp_error;
    bit          response_received;

    function new(string name = "gpu_item");
        super.new(name);
        response_received = 1'b0;
    endfunction

    // Converte a transacao de alto nivel no formato fisico do protocolo.
    //facilita a escrita com o drive
    function logic [41:0] pack_request();
        return {packet_type, field_0, field_1, field_2, field_3, field_4};
    endfunction

    function string convert2string();
        return $sformatf(
            "type=%s fields=%02h_%02h_%02h_%02h_%02h rsp=%08h err=%0b received=%0b",
            packet_type.name(), field_0, field_1, field_2, field_3, field_4,
            rsp_data, rsp_error, response_received
        );
    endfunction

endclass
