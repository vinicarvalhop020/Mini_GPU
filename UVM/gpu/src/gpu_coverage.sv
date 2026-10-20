`include "uvm_macros.svh"
import uvm_pkg::*;

// Cobertura funcional do protocolo do host. Assim como o scoreboard, este
// componente recebe as transacoes completas publicadas pelo monitor; porem,
// ele apenas registra quais situacoes foram exercitadas.
class gpu_coverage extends uvm_component;
    `uvm_component_utils(gpu_coverage)

    uvm_analysis_imp #(gpu_item, gpu_coverage) analysis_export;

    int unsigned sampled_transactions;

    // Cada amostra representa uma requisicao que foi aceita e cuja resposta
    // ja foi observada. Portanto, os sinais do protocolo nao sao amostrados
    // diretamente: a cobertura trabalha no nivel da transacao UVM.
    covergroup transaction_cg with function sample(
        gpu_packet_type_e packet_type,
        logic [7:0]       field_0,
        logic [7:0]       field_1,
        logic [7:0]       field_2,
        logic [7:0]       field_3,
        logic [7:0]       field_4,
        logic [63:0]      rsp_data,
        logic             rsp_error
    );
        option.per_instance = 1;

        // Os quatro tipos de pacote aceitos pela interface de host.
        cp_packet_type: coverpoint packet_type {
            bins mem_read  = {GPU_MEM_READ};
            bins mem_write = {GPU_MEM_WRITE};
            bins command   = {GPU_COMMAND};
            bins start     = {GPU_START};
        }

        // Enderecos das leituras e escritas, agrupados em regioes da memoria.
        cp_memory_address: coverpoint field_0
            iff (packet_type inside {GPU_MEM_READ, GPU_MEM_WRITE}) {
            bins zero = {8'h00};
            bins low  = {[8'h01:8'h3f]};
            bins mid  = {[8'h40:8'hbf]};
            bins high = {[8'hc0:8'hfe]};
            bins max  = {8'hff};
        }

        // Campos do pacote GPU_COMMAND: opcode, SRC_A, SRC_B e DST.
        cp_opcode: coverpoint field_1 iff (packet_type == GPU_COMMAND) {
            bins add = {8'h01};
            bins sub = {8'h02};
            bins mul = {8'h03};
            bins div = {8'h04};
        }

        cp_src_a_region: coverpoint field_2 iff (packet_type == GPU_COMMAND) {
            bins q0 = {[8'h00:8'h3f]};
            bins q1 = {[8'h40:8'h7f]};
            bins q2 = {[8'h80:8'hbf]};
            bins q3 = {[8'hc0:8'hff]};
        }

        cp_src_b_region: coverpoint field_3 iff (packet_type == GPU_COMMAND) {
            bins q0 = {[8'h00:8'h3f]};
            bins q1 = {[8'h40:8'h7f]};
            bins q2 = {[8'h80:8'hbf]};
            bins q3 = {[8'hc0:8'hff]};
        }

        cp_dst_region: coverpoint field_4 iff (packet_type == GPU_COMMAND) {
            bins q0 = {[8'h00:8'h3f]};
            bins q1 = {[8'h40:8'h7f]};
            bins q2 = {[8'h80:8'hbf]};
            bins q3 = {[8'hc0:8'hff]};
        }

        // Relaciona cada opcode com a regiao de memoria que recebe o resultado.
        opcode_x_dst_region: cross cp_opcode, cp_dst_region;

        // START precisa retornar DONE. rsp_error indica overflow aritmetico
        // ou divisao por zero e tambem deve ser exercitado.
        cp_start_done: coverpoint rsp_data[1] iff (packet_type == GPU_START) {
            bins done = {1'b1};
        }

        cp_rsp_error: coverpoint rsp_error {
            bins no_error         = {1'b0};
            bins arithmetic_error = {1'b1};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export      = new("analysis_export", this);
        transaction_cg       = new();
        sampled_transactions = 0;
    endfunction

    // Chamado pelo analysis_export para cada item publicado pelo monitor.
    function void write(gpu_item transaction);
        sampled_transactions++;
        transaction_cg.sample(transaction.packet_type,
                              transaction.field_0,
                              transaction.field_1,
                              transaction.field_2,
                              transaction.field_3,
                              transaction.field_4,
                              transaction.rsp_data,
                              transaction.rsp_error);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("GPU_COV",
                  $sformatf("Cobertura funcional: %0.2f%% (%0d transacoes amostradas).",
                            transaction_cg.get_inst_coverage(),
                            sampled_transactions),
                  UVM_NONE)
    endfunction

endclass
