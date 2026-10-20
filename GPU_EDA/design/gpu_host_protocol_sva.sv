`ifdef ASSERTIONS

// Verifica a conformidade do host com a GPU SIMD
module gpu_host_protocol_sva (
    input logic        clk,
    input logic        rst,
    input logic [41:0] req_payload,
    input logic        req_valid,
    input logic        req_ready,
    input logic        rsp_valid,
    input logic        rsp_error
);

    // Host apresenta uma nova requisição mas gpu nao esta pronta ainda para aceitá-la, 
    // o host deve manter a requisicao e seu payload estavel até que a GPU possa aceitar
    property p_request_stable_while_waiting;
        @(posedge clk) disable iff (rst)
            (req_valid && !req_ready) |=> (req_valid && $stable(req_payload));
    endproperty

    a_request_stable_while_waiting: assert property (p_request_stable_while_waiting)
        else $error("[SVA][HOST] Requisicao mudou enquanto req_ready estava baixo.");

    // gpu informa que rsp_valid esta ativo apenas por um ciclo
    property p_response_is_one_cycle;
        @(posedge clk) disable iff (rst)
            rsp_valid |=> !rsp_valid;
    endproperty

    a_response_is_one_cycle: assert property (p_response_is_one_cycle)
        else $error("[SVA][HOST] rsp_valid permaneceu alto por mais de um ciclo.");

    // Um erro somente pode acompanhar uma resposta valida da GPU.
    property p_error_only_with_response;
        @(posedge clk) disable iff (rst)
            rsp_error |-> rsp_valid;
    endproperty

    a_error_only_with_response: assert property (p_error_only_with_response)
        else $error("[SVA][HOST] rsp_error foi ativado sem rsp_valid.");

endmodule

`endif
