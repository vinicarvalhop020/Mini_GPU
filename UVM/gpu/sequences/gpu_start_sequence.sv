`include "uvm_macros.svh"
import uvm_pkg::*;

// Inicia o comando que ja esta armazenado no Scheduler.
class gpu_start_sequence extends uvm_sequence #(gpu_item);
    `uvm_object_utils(gpu_start_sequence)

    function new(string name = "gpu_start_sequence");
        super.new(name);
    endfunction

    virtual task body();
        gpu_item request;

        request = gpu_item::type_id::create("request");
        start_item(request);

        request.packet_type = GPU_START;
        request.field_0     = 8'h00;
        request.field_1     = 8'h00;
        request.field_2     = 8'h00;
        request.field_3     = 8'h00;
        request.field_4     = 8'h00;

        finish_item(request);

        `uvm_info("GPU_SEQ",
                  $sformatf("GPU_START concluido: %s", request.convert2string()),
                  UVM_LOW)
    endtask

endclass
