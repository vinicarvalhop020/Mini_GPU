`include "uvm_macros.svh"
import uvm_pkg::*;

class gpu_sequencer extends uvm_sequencer #(gpu_item);
    `uvm_component_utils(gpu_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
