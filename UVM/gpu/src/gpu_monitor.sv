`include "uvm_macros.svh"
import uvm_pkg::*;

class gpu_monitor extends uvm_monitor;
    `uvm_component_utils(gpu_monitor)

    virtual gpu_host_if vif;
    uvm_analysis_port #(gpu_item) item_collected_port;

    // O decoder pode aceitar uma proxima requisicao antes da resposta da
    // anterior. A fila preserva a ordem entre handshakes e respostas.
    gpu_item pending_requests[$];

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
                pending_requests.delete();
                continue;
            end

            // um pacote de requisicao foi aceito pelo DUT
            // O monitor vai observar a requisicao aceita e criar um item correspondente
            if (vif.monitor_cb.req_valid && vif.monitor_cb.req_ready) begin
                gpu_item observed_request;
                observed_request = gpu_item::type_id::create("observed_request");
                // salva os campos do pacote de requisicao no item pendente
                observed_request.packet_type =
                    gpu_packet_type_e'(vif.monitor_cb.req_payload[41:40]);
                observed_request.field_0 = vif.monitor_cb.req_payload[39:32];
                observed_request.field_1 = vif.monitor_cb.req_payload[31:24];
                observed_request.field_2 = vif.monitor_cb.req_payload[23:16];
                observed_request.field_3 = vif.monitor_cb.req_payload[15:8];
                observed_request.field_4 = vif.monitor_cb.req_payload[7:0];
                pending_requests.push_back(observed_request);

                `uvm_info("GPU_MON",
                          $sformatf("Requisicao observada: %s",
                                    observed_request.convert2string()),
                          UVM_LOW)
            end

            // A resposta conclui a transacao pendente e a envia aos assinantes.
            // rsp_valid indica que a resposta do DUT esta disponivel
            if (vif.monitor_cb.rsp_valid) begin
                if (pending_requests.size() == 0) begin
                    `uvm_error("GPU_MON", "rsp_valid sem requisicao pendente")
                end else begin
                    gpu_item pending_request;
                    pending_request = pending_requests.pop_front();
                    pending_request.rsp_data          = vif.monitor_cb.rsp_data;
                    pending_request.rsp_error         = vif.monitor_cb.rsp_error;
                    pending_request.response_received = 1'b1;

                    item_collected_port.write(pending_request); // envia o item coletado para os assinantes

                    `uvm_info("GPU_MON",
                              $sformatf("Resposta observada: %s",
                                        pending_request.convert2string()),
                              UVM_LOW)
                end
            end
        end
    endtask

endclass
