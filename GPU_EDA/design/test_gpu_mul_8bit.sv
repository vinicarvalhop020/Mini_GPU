`include "uvm_macros.svh"
import uvm_pkg::*;

// Confere que uma operacao MUL preserva -128 x -128 em 16 bits por lane.
class test_gpu_mul_8bit extends gpu_base_test;
    `uvm_component_utils(test_gpu_mul_8bit)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_mul_8bit_sequence gpu_seq;

        gpu_seq = gpu_mul_8bit_sequence::type_id::create("gpu_seq");
        phase.raise_objection(this);
        gpu_seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
