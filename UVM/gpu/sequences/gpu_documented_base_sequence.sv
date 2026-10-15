`include "uvm_macros.svh"
import uvm_pkg::*;

// Operacoes de host reutilizadas pelos cenarios rastreaveis do documento.
class gpu_documented_base_sequence extends uvm_sequence #(gpu_item);
    `uvm_object_utils(gpu_documented_base_sequence)

    function new(string name = "gpu_documented_base_sequence");
        super.new(name);
    endfunction

    task automatic send_packet(
        input  gpu_packet_type_e packet_type,
        input  logic [7:0]       field_0,
        input  logic [7:0]       field_1,
        input  logic [7:0]       field_2,
        input  logic [7:0]       field_3,
        input  logic [7:0]       field_4,
        output logic [31:0]      response_data
    );
        gpu_item request;

        request = gpu_item::type_id::create("request");
        start_item(request);
        request.packet_type = packet_type;
        request.field_0     = field_0;
        request.field_1     = field_1;
        request.field_2     = field_2;
        request.field_3     = field_3;
        request.field_4     = field_4;
        finish_item(request);

        response_data = request.rsp_data;
    endtask

    task automatic write_vector(
        input logic [7:0]  address,
        input logic [31:0] vector_data
    );
        logic [31:0] response_data;

        send_packet(GPU_MEM_WRITE, address,
                    vector_data[31:24], vector_data[23:16],
                    vector_data[15:8], vector_data[7:0], response_data);
    endtask

    task automatic read_vector(
        input  logic [7:0]  address,
        output logic [31:0] vector_data
    );
        send_packet(GPU_MEM_READ, address, 8'h00, 8'h00, 8'h00, 8'h00,
                    vector_data);
    endtask

    task automatic execute_operation(
        input logic [7:0] opcode,
        input logic [7:0] src_a,
        input logic [7:0] src_b,
        input logic [7:0] dst
    );
        logic [31:0] response_data;

        send_packet(GPU_COMMAND, 8'h00, opcode, src_a, src_b, dst,
                    response_data);
        send_packet(GPU_START, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
                    response_data);
    endtask
endclass
