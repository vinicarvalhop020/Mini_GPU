`include "uvm_macros.svh"
import uvm_pkg::*;

// Executa 1.000 operacoes aleatorias. O scoreboard verifica as respostas e o
// componente gpu_coverage registra a cobertura funcional observada.
class test_gpu_random extends gpu_base_test;
    `uvm_component_utils(test_gpu_random)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Evita milhares de mensagens por transacao durante a campanha aleatoria.
    // UVM_ERROR continua visivel, assim como os resumos UVM_NONE do scoreboard
    // e da cobertura funcional ao final da simulacao.
    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_top.set_report_verbosity_level_hier(UVM_NONE);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_random_sequence gpu_seq;

        gpu_seq = gpu_random_sequence::type_id::create("gpu_seq");
        phase.raise_objection(this);
        gpu_seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass
