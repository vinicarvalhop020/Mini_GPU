`include "uvm_macros.svh"
import uvm_pkg::*;
class test_gpu_back_to_back extends gpu_documented_base_test;
    `uvm_component_utils(test_gpu_back_to_back)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_documented_back_to_back_sequence sequence;

        sequence = gpu_documented_back_to_back_sequence::type_id::create("sequence");
        phase.raise_objection(this);
        sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
