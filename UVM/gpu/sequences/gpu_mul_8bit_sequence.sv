`include "uvm_macros.svh"
import uvm_pkg::*;

// Valida o produto maximo de duas entradas unsigned de 8 bits em todas as lanes.
class gpu_mul_8bit_sequence extends gpu_base_sequence;
    `uvm_object_utils(gpu_mul_8bit_sequence)

    localparam logic [63:0] EXPECTED_PRODUCT = 64'hFE01_FE01_FE01_FE01;

    function new(string name = "gpu_mul_8bit_sequence");
        super.new(name);
    endfunction

    virtual task body();
        logic [63:0] read_data;

        write_vector(8'h00, 32'hFFFF_FFFF);
        write_vector(8'h01, 32'hFFFF_FFFF);
        execute_operation(8'h03, 8'h00, 8'h01, 8'h10);
        read_vector(8'h10, read_data);

        if (read_data !== EXPECTED_PRODUCT)
            `uvm_error("GPU_MUL_8",
                       $sformatf("255 x 255: esperado=%016h recebido=%016h",
                                 EXPECTED_PRODUCT, read_data))
        else
            `uvm_info("GPU_MUL_8", "255 x 255 preservado nas quatro lanes",
                      UVM_LOW)
    endtask
endclass
