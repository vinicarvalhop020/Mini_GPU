`include "uvm_macros.svh"
import uvm_pkg::*;

// Aplica reset em IDLE e durante uma operacao, verificando o retorno ao estado inicial.
class test_gpu_reset extends gpu_base_test;
    `uvm_component_utils(test_gpu_reset)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task automatic check_reset_state(input string context);
        @(internal_vif.monitor_cb);
        check_condition(internal_vif.monitor_cb.fsm_state == 3'b000,
                        {context, ": FSM nao retornou a IDLE"});
        check_condition(internal_vif.monitor_cb.scheduler_state == 2'b00,
                        {context, ": Scheduler nao retornou a IDLE"});
        check_condition(!internal_vif.monitor_cb.cmd_busy &&
                        !internal_vif.monitor_cb.cmd_done,
                        {context, ": BUSY ou DONE nao foi limpo"});
    endtask

    virtual task run_phase(uvm_phase phase);
        gpu_reset_sequence gpu_seq;
        bit read_a_seen;

        gpu_seq = gpu_reset_sequence::type_id::create("gpu_seq");

        phase.raise_objection(this);

        // A primeira verificacao aplica reset sem nenhuma operacao pendente.
        wait (host_vif.rst === 1'b0);
        @(negedge host_vif.clk);
        host_vif.rst = 1'b1;
        repeat (2) @(posedge host_vif.clk);
        @(negedge host_vif.clk);
        host_vif.rst = 1'b0;
        check_reset_state("Reset em IDLE");

        // A segunda verificacao interrompe uma operacao apos a leitura de A.
        fork
            gpu_seq.start(env.agent.sequencer);
            begin
                wait_for_fsm_state(3'b001, 100, read_a_seen);
                check_condition(read_a_seen, "Reset: FSM nao iniciou a operacao");

                if (read_a_seen) begin
                    @(negedge host_vif.clk);
                    host_vif.rst = 1'b1;
                    repeat (2) @(posedge host_vif.clk);
                    @(negedge host_vif.clk);
                    host_vif.rst = 1'b0;
                    check_reset_state("Reset durante READ_A");
                end
            end
        join
        phase.drop_objection(this);
    endtask
endclass
