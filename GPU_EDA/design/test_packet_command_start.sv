`include "uvm_macros.svh"
import uvm_pkg::*;

// Envia GPU_COMMAND seguido de GPU_START e observa o comando entregue ao Scheduler.
class test_packet_command_start extends gpu_base_test;
    `uvm_component_utils(test_packet_command_start)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_add_sequence gpu_seq;
        bit command_seen;

        gpu_seq = gpu_add_sequence::type_id::create("gpu_seq");
        command_seen = 1'b0;

        phase.raise_objection(this);
        fork
            gpu_seq.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 100; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if (internal_vif.monitor_cb.cmd_valid) begin
                        check_condition(internal_vif.monitor_cb.cmd_fields == 32'h01_00_01_10,
                               "GPU_START nao entregou os campos corretos ao Scheduler");
                        command_seen = 1'b1;
                        break;
                    end
                end
            end
        join
        check_condition(command_seen, "GPU_START nao ativou cmd_valid");
        phase.drop_objection(this);
    endtask
endclass
