`include "uvm_macros.svh"
import uvm_pkg::*;
class test_packet_command_start extends gpu_documented_base_test;
    `uvm_component_utils(test_packet_command_start)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_operation_sequence sequence;
        bit command_seen;

        sequence = gpu_operation_sequence::type_id::create("sequence");
        sequence.opcode = 8'h03;
        sequence.src_a  = 8'h12;
        sequence.src_b  = 8'h34;
        sequence.dst    = 8'h56;
        command_seen = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 100; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if (internal_vif.monitor_cb.cmd_valid) begin
                        expect(internal_vif.monitor_cb.cmd_fields == 32'h03_12_34_56,
                               "GPU_START nao entregou os campos corretos ao Scheduler");
                        command_seen = 1'b1;
                        break;
                    end
                end
            end
        join
        expect(command_seen, "GPU_START nao ativou cmd_valid");
        phase.drop_objection(this);
    endtask
endclass
