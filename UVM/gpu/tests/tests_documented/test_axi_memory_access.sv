`include "uvm_macros.svh"
import uvm_pkg::*;
class test_axi_memory_access extends test_packet_mem_read;
    `uvm_component_utils(test_axi_memory_access)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
