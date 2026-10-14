`include "uvm_macros.svh"
import uvm_pkg::*;

// Sequence inicial, direcionada, usada somente para comprovar o fluxo UVM.
class gpu_mem_write_sequence extends uvm_sequence #(gpu_item);
    `uvm_object_utils(gpu_mem_write_sequence)

    // O test que iniciar esta sequence pode alterar estes valores antes de start().
    logic [7:0]  address;
    logic [31:0] vector_data;

    function new(string name = "gpu_mem_write_sequence");
        super.new(name);
        address     = 8'h00;
        vector_data = 32'h01_02_03_04;
    endfunction

    virtual task body();
        gpu_item request;

        request = gpu_item::type_id::create("request");

        start_item(request);

        // MEM_WRITE: field_1 e a lane mais significativa do vetor.
        request.packet_type = GPU_MEM_WRITE;
        request.field_0     = address;
        request.field_1     = vector_data[31:24];
        request.field_2     = vector_data[23:16];
        request.field_3     = vector_data[15:8];
        request.field_4     = vector_data[7:0];

        finish_item(request);

        `uvm_info("GPU_SEQ",
                  $sformatf("Transacao concluida: %s", request.convert2string()),
                  UVM_LOW)
    endtask

endclass
