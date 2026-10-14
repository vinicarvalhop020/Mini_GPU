`include "uvm_macros.svh"
import uvm_pkg::*;

// O sequencer apenas arbitra e encaminha gpu_item para o driver.
class gpu_sequencer extends uvm_sequencer #(gpu_item);
    `uvm_component_utils(gpu_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
