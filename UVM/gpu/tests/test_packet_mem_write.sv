`include "uvm_macros.svh"
import uvm_pkg::*;

// [AXI_02] Envia MEM_WRITE e verifica endereco, dado, escrita na memoria e resposta ao host.
class test_packet_mem_write extends gpu_base_test;
    `uvm_component_utils(test_packet_mem_write)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_mem_access_sequence sequence;
        bit write_seen;

        sequence = gpu_mem_access_sequence::type_id::create("sequence");
        write_seen = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 30; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if (internal_vif.monitor_cb.mem_a_we) begin
                        expect(internal_vif.monitor_cb.mem_a_addr == 8'h00,
                               "MEM_WRITE apresentou endereco incorreto na porta A");
                        expect(internal_vif.monitor_cb.mem_a_wdata == 32'h01_02_03_04,
                               "MEM_WRITE apresentou dado incorreto na porta A");
                        write_seen = 1'b1;
                        break;
                    end
                end
            end
        join
        expect(write_seen, "MEM_WRITE nao ativou mem_a_we");
        phase.drop_objection(this);
    endtask
endclass
