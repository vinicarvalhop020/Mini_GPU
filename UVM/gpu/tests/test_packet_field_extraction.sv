`include "uvm_macros.svh"
import uvm_pkg::*;

// Verifica a extracao de TYPE e FIELD_0 a FIELD_4 de um pacote.
class test_packet_field_extraction extends gpu_base_test;
    `uvm_component_utils(test_packet_field_extraction)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_mem_access_sequence sequence;
        bit fields_checked;

        sequence = gpu_mem_access_sequence::type_id::create("sequence");
        fields_checked = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 20; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if (internal_vif.monitor_cb.decoded_valid) begin
                        check_condition(internal_vif.monitor_cb.req_type == GPU_MEM_WRITE,
                               "TYPE nao foi extraido como MEM_WRITE");
                        check_condition(internal_vif.monitor_cb.field_0 == 8'h00,
                               "FIELD_0 nao foi extraido corretamente");
                        check_condition(internal_vif.monitor_cb.field_1 == 8'h01 &&
                               internal_vif.monitor_cb.field_2 == 8'h02 &&
                               internal_vif.monitor_cb.field_3 == 8'h03 &&
                               internal_vif.monitor_cb.field_4 == 8'h04,
                               "FIELD_1..FIELD_4 nao foram extraidos corretamente");
                        fields_checked = 1'b1;
                        break;
                    end
                end
            end
        join
        check_condition(fields_checked, "Packet Decoder nao apresentou campos decodificados");
        phase.drop_objection(this);
    endtask
endclass
