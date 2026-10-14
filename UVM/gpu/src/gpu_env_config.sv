`include "uvm_macros.svh"
import uvm_pkg::*;

// Configuracao do ambiente. Outros controles serao adicionados aqui quando
// scoreboard e coverage fizerem parte do escopo.
class gpu_env_config extends uvm_object;
    `uvm_object_utils(gpu_env_config)

    gpu_agent_config agent_cfg;

    function new(string name = "gpu_env_config");
        super.new(name);
        agent_cfg = gpu_agent_config::type_id::create("agent_cfg");
    endfunction

endclass
