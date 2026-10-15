`include "uvm_macros.svh"
import uvm_pkg::*;

// Base reutilizavel dos testes da GPU
class gpu_base_test extends uvm_test;
    `uvm_component_utils(gpu_base_test)

    gpu_env        env;
    gpu_env_config env_cfg;
    virtual gpu_host_if     host_vif;
    virtual gpu_internal_if internal_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env_cfg = gpu_env_config::type_id::create("env_cfg");
        env_cfg.agent_cfg.is_active = UVM_ACTIVE;

        if (!uvm_config_db#(virtual gpu_host_if)::get(this, "", "host_vif",
                                                       host_vif))
            `uvm_fatal("NO_HOST_VIF", "Interface de host nao foi configurada")

        if (!uvm_config_db#(virtual gpu_internal_if)::get(this, "", "internal_vif",
                                                           internal_vif))
            `uvm_fatal("NO_INTERNAL_VIF",
                       "Interface interna de verificacao nao foi configurada")

        uvm_config_db#(gpu_env_config)::set(this, "env", "cfg", env_cfg);
        env = gpu_env::type_id::create("env", this);
    endfunction

    // Helpers compartilhados por todos os testes da GPU.
    function void expect(input bit condition, input string message);
        if (!condition)
            `uvm_error("GPU_TEST", message)
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
