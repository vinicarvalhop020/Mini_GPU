`include "uvm_macros.svh"
import uvm_pkg::*;
class test_gpu_random extends gpu_documented_base_test;
    `uvm_component_utils(test_gpu_random)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_documented_random_sequence sequence;

        sequence = gpu_documented_random_sequence::type_id::create("sequence");
        phase.raise_objection(this);
        sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
