`include "uvm_macros.svh"
import uvm_pkg::*;

// Verifica a sequencia de estados e os pulsos de controle da FSM.
class test_fsm_sequence extends gpu_base_test;
    `uvm_component_utils(test_fsm_sequence)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        gpu_add_sequence sequence;
        logic [2:0] expected_states [0:6];
        int unsigned next_state;
        bit sequence_seen;

        sequence = gpu_add_sequence::type_id::create("sequence");

        expected_states[0] = 3'b001; // READ_A
        expected_states[1] = 3'b010; // LOAD_A
        expected_states[2] = 3'b011; // READ_B
        expected_states[3] = 3'b100; // LOAD_B
        expected_states[4] = 3'b101; // EXECUTE
        expected_states[5] = 3'b110; // WRITE_RESULT
        expected_states[6] = 3'b111; // FINISH
        next_state = 0;
        sequence_seen = 1'b0;

        phase.raise_objection(this);
        fork
            sequence.start(env.agent.sequencer);
            begin
                for (int unsigned cycle = 0; cycle < 100; cycle++) begin
                    @(internal_vif.monitor_cb);
                    if ((next_state < 7) &&
                        (internal_vif.monitor_cb.fsm_state == expected_states[next_state])) begin
                        next_state++;
                        if (next_state == 7) begin
                            sequence_seen = 1'b1;
                            break;
                        end
                    end
                end
            end
        join
        expect(sequence_seen, "FSM nao percorreu READ_A ate FINISH na ordem esperada");
        phase.drop_objection(this);
    endtask
endclass
