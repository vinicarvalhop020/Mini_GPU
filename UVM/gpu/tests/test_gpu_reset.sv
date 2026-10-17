`include "uvm_macros.svh"
import uvm_pkg::*;

// Aplica reset ocioso e durante uma operacao e verifica o retorno ao estado inicial.
class test_gpu_reset extends gpu_base_test;
    `uvm_component_utils(test_gpu_reset)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_add_sequence sequence;
        bit read_a_seen;

        sequence = gpu_add_sequence::type_id::create("sequence");

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                wait_for_fsm_state(3'b001, 100, read_a_seen);
                expect(read_a_seen, "Reset: FSM nao iniciou a operacao");

                if (read_a_seen) begin
                    @(negedge host_vif.clk);
                    host_vif.rst = 1'b1;
                    repeat (2) @(posedge host_vif.clk);
                    host_vif.rst = 1'b0;

                    @(internal_vif.monitor_cb);
                    expect(internal_vif.monitor_cb.fsm_state == 3'b000,
                           "Reset nao retornou a FSM para IDLE");
                    expect(internal_vif.monitor_cb.scheduler_state == 2'b00,
                           "Reset nao retornou o Scheduler para IDLE");
                    expect(!internal_vif.monitor_cb.cmd_busy &&
                           !internal_vif.monitor_cb.cmd_done,
                           "Reset nao limpou BUSY e DONE");
                end
            end
        join
        phase.drop_objection(this);
    endtask
endclass
