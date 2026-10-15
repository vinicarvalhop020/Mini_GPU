`include "uvm_macros.svh"
import uvm_pkg::*;
class test_packet_mem_write extends gpu_documented_base_test;
    `uvm_component_utils(test_packet_mem_write)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_mem_write_sequence sequence;
        bit write_seen;

        sequence = gpu_mem_write_sequence::type_id::create("sequence");
        sequence.address     = 8'h12;
        sequence.vector_data = 32'hAA_BB_CC_DD;
        write_seen = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 30; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if (internal_vif.monitor_cb.mem_a_we) begin
                        expect(internal_vif.monitor_cb.mem_a_addr == 8'h12,
                               "MEM_WRITE apresentou endereco incorreto na porta A");
                        expect(internal_vif.monitor_cb.mem_a_wdata == 32'hAA_BB_CC_DD,
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
