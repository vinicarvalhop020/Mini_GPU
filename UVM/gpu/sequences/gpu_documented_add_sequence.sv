`include "uvm_macros.svh"
import uvm_pkg::*;

// [GPU_02_END_TO_END]: programa completo de soma vetorial.
class gpu_documented_add_sequence extends gpu_documented_base_sequence;
    `uvm_object_utils(gpu_documented_add_sequence)

    function new(string name = "gpu_documented_add_sequence");
        super.new(name);
    endfunction

    virtual task body();
        logic [31:0] read_data;

        write_vector(8'h00, 32'h01_02_03_04);
        write_vector(8'h01, 32'h05_06_07_08);
        execute_operation(8'h01, 8'h00, 8'h01, 8'h10);
        read_vector(8'h10, read_data);
    endtask
endclass
