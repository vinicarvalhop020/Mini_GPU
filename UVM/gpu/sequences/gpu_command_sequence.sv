`include "uvm_macros.svh"
import uvm_pkg::*;

// Programa apenas um commando ao Scheduler da GPU
class gpu_command_sequence extends uvm_sequence #(gpu_item);
    `uvm_object_utils(gpu_command_sequence)

    logic [7:0] opcode;
    logic [7:0] src_a;
    logic [7:0] src_b;
    logic [7:0] dst;

    function new(string name = "gpu_command_sequence");
        super.new(name);
        opcode = 8'h01; // ADD
        src_a  = 8'h00;
        src_b  = 8'h01;
        dst    = 8'h02;
    endfunction

    virtual task body();
        gpu_item request;

        request = gpu_item::type_id::create("request");
        start_item(request);

        // FIELD_0 e reservado para GPU_COMMAND.
        request.packet_type = GPU_COMMAND;
        request.field_0     = 8'h00;
        request.field_1     = opcode;
        request.field_2     = src_a;
        request.field_3     = src_b;
        request.field_4     = dst;

        finish_item(request);

        `uvm_info("GPU_SEQ",
                  $sformatf("GPU_COMMAND concluido: %s", request.convert2string()),
                  UVM_LOW)
    endtask

endclass
