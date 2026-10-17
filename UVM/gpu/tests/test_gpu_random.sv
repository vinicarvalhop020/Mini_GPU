`include "uvm_macros.svh"
import uvm_pkg::*;

// Gera vetores, opcodes e enderecos aleatorios e compara as respostas com o modelo de referencia.
class test_gpu_random extends gpu_base_test;
    `uvm_component_utils(test_gpu_random)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_random_sequence gpu_seq;

        gpu_seq = gpu_random_sequence::type_id::create("gpu_seq");
        phase.raise_objection(this);
        gpu_seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
