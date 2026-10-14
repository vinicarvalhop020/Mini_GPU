`include "uvm_macros.svh"
import uvm_pkg::*;

// Solicita a leitura de um vetor da memoria vetorial.
class gpu_mem_read_sequence extends uvm_sequence #(gpu_item);
    `uvm_object_utils(gpu_mem_read_sequence)

    logic [7:0] address;

    function new(string name = "gpu_mem_read_sequence");
        super.new(name);
        address = 8'h00;
    endfunction

    virtual task body();
        gpu_item request;

        request = gpu_item::type_id::create("request");
        start_item(request);

        request.packet_type = GPU_MEM_READ;
        request.field_0     = address;
        request.field_1     = 8'h00;
        request.field_2     = 8'h00;
        request.field_3     = 8'h00;
        request.field_4     = 8'h00;

        finish_item(request);

        `uvm_info("GPU_SEQ",
                  $sformatf("MEM_READ concluido: %s", request.convert2string()),
                  UVM_LOW)
    endtask

endclass
