`ifdef ASSERTIONS

// Verifica o protocolo host <-> GPU na borda externa do projeto.
module gpu_host_protocol_sva (
    input logic        clk,
    input logic        rst,
    input logic [41:0] req_payload,
    input logic        req_valid,
    input logic        req_ready,
    input logic        rsp_valid,
    input logic        rsp_error
);

    // Enquanto a GPU ainda nao aceita a requisicao, o host deve mante-la.
    property p_request_stable_while_waiting;
        @(posedge clk) disable iff (rst)
            (req_valid && !req_ready) |=> (req_valid && $stable(req_payload));
    endproperty

    a_request_stable_while_waiting: assert property (p_request_stable_while_waiting)
        else $error("[SVA][HOST] Requisicao mudou enquanto req_ready estava baixo.");

    // Nesta versao da interface, uma resposta ocupa somente um ciclo.
    property p_response_is_one_cycle;
        @(posedge clk) disable iff (rst)
            rsp_valid |=> !rsp_valid;
    endproperty

    a_response_is_one_cycle: assert property (p_response_is_one_cycle)
        else $error("[SVA][HOST] rsp_valid permaneceu alto por mais de um ciclo.");

    // O AXI simplificado ainda nao implementa respostas de erro.
    property p_no_response_error;
        @(posedge clk) disable iff (rst)
            !rsp_error;
    endproperty

    a_no_response_error: assert property (p_no_response_error)
        else $error("[SVA][HOST] rsp_error foi ativado sem suporte a erro implementado.");

endmodule

`endif
