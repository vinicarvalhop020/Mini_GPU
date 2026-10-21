`include "uvm_macros.svh"
import uvm_pkg::*;

// Confere que o host segura o segundo pacote enquanto req_ready esta baixo.
class test_host_backpressure extends gpu_base_test;
    `uvm_component_utils(test_host_backpressure)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        logic [41:0] first_packet;
        logic [41:0] second_packet;
        int response_count;

        first_packet   = {2'b01, 8'h60, 8'h01, 8'h02, 8'h03, 8'h04};
        second_packet  = {2'b01, 8'h61, 8'h05, 8'h06, 8'h07, 8'h08};
        response_count = 0;

        phase.raise_objection(this);

        while (host_vif.driver_cb.rst !== 1'b0)
            @(host_vif.driver_cb);

        // Primeiro pacote: sera aceito pelo decoder.
        @(host_vif.driver_cb);
        host_vif.driver_cb.req_payload <= first_packet;
        host_vif.driver_cb.req_valid   <= 1'b1;

        @(host_vif.driver_cb);
        check_condition(host_vif.driver_cb.req_ready,
                        "Primeiro pacote nao foi aceito pelo decoder");

        // O segundo pacote e apresentado logo depois. Nesta fase o decoder
        // esta ocupado e o host deve manter os sinais estaveis.
        host_vif.driver_cb.req_payload <= second_packet;

        @(host_vif.driver_cb);
        check_condition(!host_vif.driver_cb.req_ready,
                        "req_ready deveria estar baixo durante o backpressure");
        check_condition(host_vif.req_valid &&
                        (host_vif.req_payload == second_packet),
                        "Host alterou valid ou payload durante o backpressure");

        @(host_vif.driver_cb);
        check_condition(host_vif.driver_cb.req_ready,
                        "Segundo pacote nao foi aceito apos o backpressure");
        check_condition(host_vif.req_valid &&
                        (host_vif.req_payload == second_packet),
                        "Host nao manteve o segundo pacote estavel ate o aceite");
        host_vif.driver_cb.req_valid <= 1'b0;

        // Os dois MEM_WRITE devem responder normalmente.
        repeat (20) begin
            @(host_vif.driver_cb);
            if (host_vif.driver_cb.rsp_valid)
                response_count++;
        end

        check_condition(response_count == 2,
                        "Os dois pacotes nao receberam resposta");
        phase.drop_objection(this);
    endtask
endclass
