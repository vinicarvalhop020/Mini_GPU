`timescale 1ns/1ps

interface gpu_host_if (
    input logic clk
);

    // Reset assincrono ativo em nivel alto.
    logic        rst;

    // Requisicao do host para a GPU.
    // {TYPE[1:0], FIELD_0, FIELD_1, FIELD_2, FIELD_3, FIELD_4}.
    logic [41:0] req_payload;
    logic        req_valid;
    logic        req_ready;

    // Resposta da GPU para o host.
    logic [31:0] rsp_data;
    logic        rsp_valid;
    logic        rsp_error;

    // Clocking block do driver
    clocking driver_cb @(posedge clk);
        default input #1step output #1step;

        input  rst;
        output req_payload;
        output req_valid;
        input  req_ready;
        input  rsp_data;
        input  rsp_valid;
        input  rsp_error;
    endclocking

    // Clocking block do monitor
    clocking monitor_cb @(posedge clk);
        default input #1step;

        input rst;
        input req_payload;
        input req_valid;
        input req_ready;
        input rsp_data;
        input rsp_valid;
        input rsp_error;
    endclocking

    // Modport usado pela instancia da GPU no top-level
    modport DUT (
        input  clk,
        input  rst,
        input  req_payload,
        input  req_valid,
        output req_ready,
        output rsp_data,
        output rsp_valid,
        output rsp_error
    );

    // Modports reservado para o driver e o monitor
    modport DRIVER  (clocking driver_cb,  input clk);
    modport MONITOR (clocking monitor_cb, input clk);

endinterface
