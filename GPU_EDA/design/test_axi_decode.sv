`include "uvm_macros.svh"
import uvm_pkg::*;

// Exercita tipos de pacote e verifica a selecao de memoria e caminho de comando.
class test_axi_decode extends gpu_base_test;
    `uvm_component_utils(test_axi_decode)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_all_ops_sequence sequence;
        bit saw_mem_write;
        bit saw_mem_read;
        bit saw_command;

        sequence = gpu_all_ops_sequence::type_id::create("sequence");
        saw_mem_write = 1'b0;
        saw_mem_read  = 1'b0;
        saw_command   = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 500; cycle++) begin
                    @(internal_vif.monitor_cb);
                    saw_mem_write |= internal_vif.monitor_cb.mem_a_we;
                    saw_mem_read  |= internal_vif.monitor_cb.mem_a_re;
                    saw_command   |= internal_vif.monitor_cb.cmd_valid;
                    if (saw_mem_write && saw_mem_read && saw_command)
                        break;
                end
            end
        join
        check_condition(saw_mem_write, "AXI nao selecionou MEM_WRITE");
        check_condition(saw_mem_read,  "AXI nao selecionou MEM_READ");
        check_condition(saw_command,   "AXI nao selecionou GPU_START/COMMAND");
        phase.drop_objection(this);
    endtask
endclass
