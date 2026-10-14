`include "uvm_macros.svh"
import uvm_pkg::*;

// Observa o protocolo de host da GPU e publica transacoes completas.
class gpu_monitor extends uvm_monitor;
    `uvm_component_utils(gpu_monitor)

    virtual gpu_host_if vif;
    uvm_analysis_port #(gpu_item) item_collected_port;

    // Como a GPU aceita uma requisicao por vez, basta guardar um item pendente
    // entre o handshake de requisicao e a resposta rsp_valid.
    gpu_item pending_request;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual gpu_host_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface gpu_host_if nao foi configurada")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(vif.monitor_cb);

            // Reset invalida qualquer transacao que ainda nao recebeu resposta.
            if (vif.monitor_cb.rst) begin
                pending_request = null;
                continue;
            end

            // Um pacote foi realmente aceito pelo DUT.
            if (vif.monitor_cb.req_valid && vif.monitor_cb.req_ready) begin
                if (pending_request != null)
                    `uvm_error("GPU_MON",
                               "Nova requisicao aceita antes da resposta anterior")

                pending_request = gpu_item::type_id::create("observed_request");
                pending_request.packet_type =
                    gpu_packet_type_e'(vif.monitor_cb.req_payload[41:40]);
                pending_request.field_0 = vif.monitor_cb.req_payload[39:32];
                pending_request.field_1 = vif.monitor_cb.req_payload[31:24];
                pending_request.field_2 = vif.monitor_cb.req_payload[23:16];
                pending_request.field_3 = vif.monitor_cb.req_payload[15:8];
                pending_request.field_4 = vif.monitor_cb.req_payload[7:0];

                `uvm_info("GPU_MON",
                          $sformatf("Requisicao observada: %s",
                                    pending_request.convert2string()),
                          UVM_LOW)
            end

            // A resposta conclui a transacao pendente e a envia aos assinantes.
            if (vif.monitor_cb.rsp_valid) begin
                if (pending_request == null) begin
                    `uvm_error("GPU_MON", "rsp_valid sem requisicao pendente")
                end else begin
                    pending_request.rsp_data          = vif.monitor_cb.rsp_data;
                    pending_request.rsp_error         = vif.monitor_cb.rsp_error;
                    pending_request.response_received = 1'b1;

                    item_collected_port.write(pending_request);

                    `uvm_info("GPU_MON",
                              $sformatf("Resposta observada: %s",
                                        pending_request.convert2string()),
                              UVM_LOW)

                    pending_request = null;
                end
            end
        end
    endtask

endclass
