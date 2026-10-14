`include "uvm_macros.svh"
import uvm_pkg::*;

// Reune os componentes associados ao protocolo de host da GPU.
class gpu_agent extends uvm_agent;
    `uvm_component_utils(gpu_agent)

    gpu_driver    driver;
    gpu_sequencer sequencer;
    gpu_monitor   monitor;

    gpu_agent_config cfg;
    uvm_analysis_port #(gpu_item) agent_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        agent_ap = new("agent_ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(gpu_agent_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("AGENT_NO_CFG", "gpu_agent_config nao foi configurada")

        if (cfg.is_active == UVM_ACTIVE) begin
            driver    = gpu_driver::type_id::create("driver", this);
            sequencer = gpu_sequencer::type_id::create("sequencer", this);
        end

        // O monitor existe tanto no agent ativo quanto no passivo.
        monitor = gpu_monitor::type_id::create("monitor", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (cfg.is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);

        monitor.item_collected_port.connect(agent_ap);
    endfunction

endclass
