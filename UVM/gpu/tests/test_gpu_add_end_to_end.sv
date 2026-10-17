`include "uvm_macros.svh"
import uvm_pkg::*;

// Executa uma soma vetorial completa pelo protocolo do host.
class test_gpu_add_end_to_end extends gpu_base_test;
    `uvm_component_utils(test_gpu_add_end_to_end)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_add_sequence gpu_seq;

        gpu_seq = gpu_add_sequence::type_id::create("gpu_seq");

        phase.raise_objection(this);
        gpu_seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
