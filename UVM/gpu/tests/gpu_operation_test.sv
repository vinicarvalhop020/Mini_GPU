`include "uvm_macros.svh"
import uvm_pkg::*;

// Exercita a sequence composta GPU_COMMAND seguido de GPU_START.
class gpu_operation_test extends gpu_base_test;
    `uvm_component_utils(gpu_operation_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_operation_sequence sequence;

        sequence = gpu_operation_sequence::type_id::create("sequence");

        phase.raise_objection(this);
        sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
