`include "uvm_macros.svh"
import uvm_pkg::*;

// Executa uma operacao completa para cada opcode suportado.
class test_gpu_all_ops extends gpu_base_test;
    `uvm_component_utils(test_gpu_all_ops)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_all_ops_sequence sequence;

        sequence = gpu_all_ops_sequence::type_id::create("sequence");
        phase.raise_objection(this);
        sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
