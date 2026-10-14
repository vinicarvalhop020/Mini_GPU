`include "uvm_macros.svh"
import uvm_pkg::*;

// Programa um comando antes de enviar GPU_START.
class gpu_start_test extends gpu_base_test;
    `uvm_component_utils(gpu_start_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_command_sequence command_sequence;
        gpu_start_sequence   start_sequence;

        command_sequence = gpu_command_sequence::type_id::create("command_sequence");
        start_sequence   = gpu_start_sequence::type_id::create("start_sequence");

        phase.raise_objection(this);
        command_sequence.start(env.agent.sequencer);
        start_sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
