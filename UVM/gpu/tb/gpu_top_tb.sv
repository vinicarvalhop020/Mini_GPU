`timescale 1ns/1ps

`include "uvm_macros.svh"
import uvm_pkg::*;
import gpu_pkg::*;

module gpu_top_tb;

    logic clk;

    gpu_host_if host_if (.clk(clk));

    gpu_simd dut (
        .clk        (host_if.clk),
        .rst        (host_if.rst),
        .req_payload(host_if.req_payload),
        .req_valid  (host_if.req_valid),
        .req_ready  (host_if.req_ready),
        .rsp_data   (host_if.rsp_data),
        .rsp_valid  (host_if.rsp_valid),
        .rsp_error  (host_if.rsp_error)
    );

`ifdef ASSERTIONS
    // Se assertions estiverem habilitadas, instancia o checker de protocolo
    gpu_host_protocol_sva u_host_protocol_sva (
        .clk         (host_if.clk),
        .rst         (host_if.rst),
        .req_payload (host_if.req_payload),
        .req_valid   (host_if.req_valid),
        .req_ready   (host_if.req_ready),
        .rsp_valid   (host_if.rsp_valid),
        .rsp_error   (host_if.rsp_error)
    );
`endif

    always #5 clk = ~clk;

    // Reset pertence ao top-level, nao ao driver UVM.
    initial begin
        clk                 = 1'b0;
        host_if.rst         = 1'b1;
        host_if.req_payload = '0;
        host_if.req_valid   = 1'b0;

        repeat (2) @(posedge clk);
        host_if.rst = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual gpu_host_if)::set(
            null, "uvm_test_top.env.agent.*", "vif", host_if
        );

        // O teste e escolhido por +UVM_TESTNAME=<nome_do_teste>.
        run_test();
    end

endmodule
