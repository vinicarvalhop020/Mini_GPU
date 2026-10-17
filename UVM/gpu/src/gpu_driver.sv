`include "uvm_macros.svh"
import uvm_pkg::*;

// Converte gpu_item em sinais do protocolo de host da GPU.
class gpu_driver extends uvm_driver #(gpu_item);
    `uvm_component_utils(gpu_driver)

    virtual gpu_host_if vif;
    gpu_item request;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual gpu_host_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface gpu_host_if nao foi configurada")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(request);
            drive_transaction(request);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_transaction(gpu_item item);
        // O driver nunca muda rst. Aguarda rst ser conhecido e desativado:
        // em t=0 ele pode valer X, que nao deve liberar uma transacao.
        while (vif.driver_cb.rst !== 1'b0)
            @(vif.driver_cb);

        // Apresenta o pacote ao DUT.
        @(vif.driver_cb);
        vif.driver_cb.req_payload <= item.pack_request(); // funcao do gpu_item que empacota a requisicao
        vif.driver_cb.req_valid   <= 1'b1;

        // Mantem valid e payload estaveis ate a GPU aceitar a requisicao.
        do
            @(vif.driver_cb);
        while (!vif.driver_cb.req_ready &&
               (vif.driver_cb.rst === 1'b0));

        // Um reset pode cancelar uma transacao que ainda aguardava aceite.
        if (vif.driver_cb.rst !== 1'b0) begin
            vif.driver_cb.req_valid <= 1'b0;
            `uvm_warning("GPU_DRV", "Requisicao cancelada por reset")
            return;
        end

        // O host desativa req_valid apos a requisicao ser aceita pelo DUT
        vif.driver_cb.req_valid <= 1'b0;

        // Espera a resposta do DUT ser validada. (rsp_valid ativo por um ciclo)
        do
            @(vif.driver_cb);
        while (!vif.driver_cb.rsp_valid &&
               (vif.driver_cb.rst === 1'b0));

        // Uma execucao interrompida por reset nao possui resposta associada.
        if (vif.driver_cb.rst !== 1'b0) begin
            `uvm_warning("GPU_DRV", "Resposta cancelada por reset")
            return;
        end

        // captura os dados da resposta da GPU
        item.rsp_data          = vif.driver_cb.rsp_data;
        item.rsp_error         = vif.driver_cb.rsp_error;
        item.response_received = 1'b1;

        `uvm_info("GPU_DRV",
                  $sformatf("Resposta recebida: %s", item.convert2string()),
                  UVM_LOW)
    endtask

endclass
