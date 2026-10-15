`include "uvm_macros.svh"
import uvm_pkg::*;

// Operacoes consecutivas devem preservar todos os destinos ja calculados.
class gpu_back_to_back_sequence extends gpu_base_sequence;
    `uvm_object_utils(gpu_back_to_back_sequence)

    function new(string name = "gpu_back_to_back_sequence");
        super.new(name);
    endfunction

    virtual task body();
        logic [31:0] read_data;

        write_vector(8'h40, 32'h01_02_03_04);
        write_vector(8'h41, 32'h05_06_07_08);

        execute_operation(8'h01, 8'h40, 8'h41, 8'h42);
        execute_operation(8'h03, 8'h40, 8'h41, 8'h43);
        execute_operation(8'h02, 8'h43, 8'h42, 8'h44);

        read_vector(8'h42, read_data);
        read_vector(8'h43, read_data);
        read_vector(8'h44, read_data);
    endtask
endclass
