`include "uvm_macros.svh"
import uvm_pkg::*;
class test_packet_mem_read extends gpu_documented_base_test;
    `uvm_component_utils(test_packet_mem_read)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_documented_mem_access_sequence sequence;
        bit read_seen;

        sequence = gpu_documented_mem_access_sequence::type_id::create("sequence");
        read_seen = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 100; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if (internal_vif.monitor_cb.mem_a_re) begin
                        read_seen = 1'b1;
                        break;
                    end
                end
            end
        join
        expect(read_seen, "MEM_READ nao ativou mem_a_re");
        phase.drop_objection(this);
    endtask
endclass
