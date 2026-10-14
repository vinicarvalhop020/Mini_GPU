`include "uvm_macros.svh"
import uvm_pkg::*;

// Teste minimo: comprova que uma sequence consegue atravessar todo o agent.
class gpu_smoke_test extends uvm_test;
    `uvm_component_utils(gpu_smoke_test)

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

    virtual task run_phase(uvm_phase phase);
        gpu_mem_write_sequence sequence;

        sequence = gpu_mem_write_sequence::type_id::create("sequence");

        phase.raise_objection(this);
        sequence.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass
