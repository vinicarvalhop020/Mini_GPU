`include "uvm_macros.svh"
import uvm_pkg::*;
class test_packet_field_extraction extends gpu_documented_base_test;
    `uvm_component_utils(test_packet_field_extraction)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_mem_write_sequence sequence;
        bit fields_checked;

        sequence = gpu_mem_write_sequence::type_id::create("sequence");
        sequence.address     = 8'hAA;
        sequence.vector_data = 32'hBB_CC_DD_EE;
        fields_checked = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 20; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if (internal_vif.monitor_cb.decoded_valid) begin
                        expect(internal_vif.monitor_cb.req_type == GPU_MEM_WRITE,
                               "TYPE nao foi extraido como MEM_WRITE");
                        expect(internal_vif.monitor_cb.field_0 == 8'hAA,
                               "FIELD_0 nao foi extraido corretamente");
                        expect(internal_vif.monitor_cb.field_1 == 8'hBB &&
                               internal_vif.monitor_cb.field_2 == 8'hCC &&
                               internal_vif.monitor_cb.field_3 == 8'hDD &&
                               internal_vif.monitor_cb.field_4 == 8'hEE,
                               "FIELD_1..FIELD_4 nao foram extraidos corretamente");
                        fields_checked = 1'b1;
                        break;
                    end
                end
            end
        join
        expect(fields_checked, "Packet Decoder nao apresentou campos decodificados");
        phase.drop_objection(this);
    endtask
endclass
