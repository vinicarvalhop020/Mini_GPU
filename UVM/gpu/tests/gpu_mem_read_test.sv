`include "uvm_macros.svh"
import uvm_pkg::*;

// Escreve um vetor e solicita sua leitura; ainda nao compara o dado lido.
class gpu_mem_read_test extends gpu_base_test;
    `uvm_component_utils(gpu_mem_read_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_mem_write_sequence write_sequence;
        gpu_mem_read_sequence  read_sequence;

        write_sequence = gpu_mem_write_sequence::type_id::create("write_sequence");
        read_sequence  = gpu_mem_read_sequence::type_id::create("read_sequence");
        read_sequence.address = write_sequence.address;

        phase.raise_objection(this);
        write_sequence.start(env.agent.sequencer);
        read_sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
