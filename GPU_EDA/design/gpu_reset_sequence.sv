`include "uvm_macros.svh"
import uvm_pkg::*;

// Prepara uma operacao que sera interrompida pelo teste de reset.
// Nao le o destino: apos o reset, a operacao pode nao ter produzido resultado.
class gpu_reset_sequence extends gpu_base_sequence;
    `uvm_object_utils(gpu_reset_sequence)

    function new(string name = "gpu_reset_sequence");
        super.new(name);
    endfunction

    virtual task body();
        write_vector(8'h00, 32'h01_02_03_04);
        write_vector(8'h01, 32'h05_06_07_08);
        execute_operation(8'h01, 8'h00, 8'h01, 8'h10);
    endtask
endclass
