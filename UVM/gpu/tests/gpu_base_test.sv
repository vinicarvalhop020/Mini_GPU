`include "uvm_macros.svh"
import uvm_pkg::*;

// Base reutilizavel dos testes da GPU
class gpu_base_test extends uvm_test;
    `uvm_component_utils(gpu_base_test)

    gpu_env        env;
    gpu_env_config env_cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env_cfg = gpu_env_config::type_id::create("env_cfg");
        env_cfg.agent_cfg.is_active = UVM_ACTIVE;

        uvm_config_db#(gpu_env_config)::set(this, "env", "cfg", env_cfg);
        env = gpu_env::type_id::create("env", this);
    endfunction

endclass
