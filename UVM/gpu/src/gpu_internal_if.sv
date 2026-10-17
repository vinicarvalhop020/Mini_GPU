`timescale 1ns/1ps

// Visao de verificacao dos sinais internos da GPU completa.
// Esta interface e instanciada por bind em gpu_simd; ela nunca dirige o RTL.
interface gpu_internal_if (
    input logic        clk,
    input logic        rst,
    input logic        decoded_valid,
    input logic        decoded_ready,
    input logic [1:0]  req_type,
    input logic [7:0]  field_0,
    input logic [7:0]  field_1,
    input logic [7:0]  field_2,
    input logic [7:0]  field_3,
    input logic [7:0]  field_4,
    input logic [7:0]  mem_a_addr,
    input logic [63:0] mem_a_wdata,
    input logic        mem_a_we,
    input logic        mem_a_re,
    input logic [31:0] cmd_fields,
    input logic        cmd_valid,
    input logic        cmd_ready,
    input logic        cmd_busy,
    input logic        cmd_done,
    input logic [31:0] exec_fields,
    input logic        exec_valid,
    input logic        exec_ready,
    input logic        exec_done,
    input logic [1:0]  scheduler_state,
    input logic [2:0]  fsm_state,
    input logic [7:0]  mem_b_addr,
    input logic        mem_b_we,
    input logic        mem_b_re,
    input logic        load_a,
    input logic        load_b,
    input logic [7:0]  alu_opcode,
    input logic [63:0] mem_b_rdata,
    input logic [63:0] vector_a,
    input logic [63:0] vector_b,
    input logic [63:0] alu_result
);

    clocking monitor_cb @(posedge clk);
        default input #1step;

        input rst;
        input decoded_valid, decoded_ready, req_type;
        input field_0, field_1, field_2, field_3, field_4;
        input mem_a_addr, mem_a_wdata, mem_a_we, mem_a_re;
        input cmd_fields, cmd_valid, cmd_ready, cmd_busy, cmd_done;
        input exec_fields, exec_valid, exec_ready, exec_done;
        input scheduler_state, fsm_state;
        input mem_b_addr, mem_b_we, mem_b_re, load_a, load_b, alu_opcode;
        input mem_b_rdata, vector_a, vector_b, alu_result;
    endclocking

endinterface
