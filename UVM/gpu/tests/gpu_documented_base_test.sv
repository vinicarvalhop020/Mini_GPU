`include "uvm_macros.svh"
import uvm_pkg::*;

// Utilitarios compartilhados pelos testes rastreaveis do plano.
class gpu_documented_base_test extends gpu_base_test;
    `uvm_component_utils(gpu_documented_base_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void expect(input bit condition, input string message);
        if (!condition)
            `uvm_error("GPU_DOC_TEST", message)
    endfunction

    task automatic wait_for_fsm_state(
        input  logic [2:0] expected_state,
        input  int unsigned maximum_cycles,
        output bit           found
    );
        found = 1'b0;

        for (int unsigned cycle = 0; cycle < maximum_cycles; cycle++) begin
            @(internal_vif.monitor_cb);
            if (internal_vif.monitor_cb.fsm_state == expected_state) begin
                found = 1'b1;
                break;
            end
        end
    endtask
endclass
