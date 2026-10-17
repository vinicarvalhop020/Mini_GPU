`include "uvm_macros.svh"
import uvm_pkg::*;

class gpu_agent_config extends uvm_object;
    `uvm_object_utils(gpu_agent_config)

    // Em UVM_ACTIVE, o agent cria driver e sequencer. Em UVM_PASSIVE,
    // somente o monitor e criado.
    uvm_active_passive_enum is_active;

    function new(string name = "gpu_agent_config");
        super.new(name);
        is_active = UVM_ACTIVE;
    endfunction

endclass
