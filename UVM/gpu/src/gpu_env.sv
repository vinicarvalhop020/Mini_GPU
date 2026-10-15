`include "uvm_macros.svh"
import uvm_pkg::*;

// Ambiente da GPU. Por enquanto possui apenas um agent de host.
class gpu_env extends uvm_env;
    `uvm_component_utils(gpu_env)

    gpu_agent agent;
    gpu_scoreboard scoreboard;
    gpu_env_config cfg;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(gpu_env_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("ENV_NO_CFG", "gpu_env_config nao foi configurada")

        uvm_config_db#(gpu_agent_config)::set(this, "agent", "cfg",
                                               cfg.agent_cfg);

        agent = gpu_agent::type_id::create("agent", this);
        scoreboard = gpu_scoreboard::type_id::create("scoreboard", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // O monitor publica cada requisicao/resposta para o modelo de referencia.
        agent.agent_ap.connect(scoreboard.analysis_export);
    endfunction

endclass
