`include "uvm_macros.svh"
import uvm_pkg::*;

// Teste minimo: comprova que uma sequence consegue atravessar todo o agent.
class gpu_smoke_test extends gpu_base_test;
    `uvm_component_utils(gpu_smoke_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_mem_write_sequence sequence;

        sequence = gpu_mem_write_sequence::type_id::create("sequence");

        phase.raise_objection(this);
        sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
