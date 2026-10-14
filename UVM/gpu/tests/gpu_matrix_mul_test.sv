`include "uvm_macros.svh"
import uvm_pkg::*;

// Executa o programa de host para C = A x B. A verificacao dos valores sera
// adicionada posteriormente pelo scoreboard.
class gpu_matrix_mul_test extends gpu_base_test;
    `uvm_component_utils(gpu_matrix_mul_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_matrix_mul_sequence sequence;

        sequence = gpu_matrix_mul_sequence::type_id::create("sequence");

        phase.raise_objection(this);
        sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
