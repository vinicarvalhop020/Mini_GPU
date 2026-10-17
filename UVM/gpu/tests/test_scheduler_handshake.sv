`include "uvm_macros.svh"
import uvm_pkg::*;

// Verifica valid/ready, BUSY, DONE e os estados do Scheduler.
class test_scheduler_handshake extends gpu_base_test;
    `uvm_component_utils(test_scheduler_handshake)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_add_sequence sequence;
        bit saw_dispatch;
        bit saw_execute;
        bit saw_done;

        sequence = gpu_add_sequence::type_id::create("sequence");
        saw_dispatch = 1'b0;
        saw_execute  = 1'b0;
        saw_done     = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 100; cycle++) begin
                    @(internal_vif.monitor_cb);
                    saw_dispatch |= (internal_vif.monitor_cb.scheduler_state == 2'b01) &&
                                    internal_vif.monitor_cb.cmd_busy;
                    saw_execute  |= (internal_vif.monitor_cb.scheduler_state == 2'b10) &&
                                    internal_vif.monitor_cb.cmd_busy;
                    saw_done     |= (internal_vif.monitor_cb.scheduler_state == 2'b11) &&
                                    internal_vif.monitor_cb.cmd_done;
                    if (saw_dispatch && saw_execute && saw_done)
                        break;
                end
            end
        join
        expect(saw_dispatch, "Scheduler nao entrou em DISPATCH com BUSY=1");
        expect(saw_execute,  "Scheduler nao entrou em EXECUTE com BUSY=1");
        expect(saw_done,     "Scheduler nao entrou em DONE com DONE=1");
        phase.drop_objection(this);
    endtask
endclass
