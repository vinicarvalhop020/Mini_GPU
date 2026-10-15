`include "uvm_macros.svh"
import uvm_pkg::*;

// [AXI_02], [AXI_03] e [MEM_01]: acessos em enderecos de borda da porta A.
class gpu_mem_access_sequence extends gpu_base_sequence;
    `uvm_object_utils(gpu_mem_access_sequence)

    function new(string name = "gpu_mem_access_sequence");
        super.new(name);
    endfunction

    virtual task body();
        logic [31:0] read_data;

        write_vector(8'h00, 32'h01_02_03_04);
        read_vector (8'h00, read_data);

        write_vector(8'h7F, 32'hA5_5A_12_34);
        read_vector (8'h7F, read_data);

        write_vector(8'hFF, 32'hDE_AD_BE_EF);
        read_vector (8'hFF, read_data);
    endtask
endclass
