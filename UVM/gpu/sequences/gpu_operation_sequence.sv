`include "uvm_macros.svh"
import uvm_pkg::*;

// Cenario composto: programa uma operacao SIMD e solicita sua execucao.
class gpu_operation_sequence extends uvm_sequence #(gpu_item);
    `uvm_object_utils(gpu_operation_sequence)

    logic [7:0] opcode;
    logic [7:0] src_a;
    logic [7:0] src_b;
    logic [7:0] dst;

    function new(string name = "gpu_operation_sequence");
        super.new(name);
        opcode = 8'h01; // ADD
        src_a  = 8'h00;
        src_b  = 8'h01;
        dst    = 8'h02;
    endfunction

    virtual task body();
        gpu_item command_request;
        gpu_item start_request;

        // Primeiro pacote: programa {opcode, src_a, src_b, dst}.
        command_request = gpu_item::type_id::create("command_request");
        start_item(command_request);

        command_request.packet_type = GPU_COMMAND;
        command_request.field_0     = 8'h00;
        command_request.field_1     = opcode;
        command_request.field_2     = src_a;
        command_request.field_3     = src_b;
        command_request.field_4     = dst;

        finish_item(command_request);

        // Segundo pacote: inicia e aguarda o termino da operacao programada.
        start_request = gpu_item::type_id::create("start_request");
        start_item(start_request);

        start_request.packet_type = GPU_START;
        start_request.field_0     = 8'h00;
        start_request.field_1     = 8'h00;
        start_request.field_2     = 8'h00;
        start_request.field_3     = 8'h00;
        start_request.field_4     = 8'h00;

        finish_item(start_request);

        `uvm_info("GPU_SEQ",
                  $sformatf("Operacao concluida: opcode=%02h src_a=%02h src_b=%02h dst=%02h status=%08h",
                            opcode, src_a, src_b, dst, start_request.rsp_data),
                  UVM_LOW)
    endtask

endclass
