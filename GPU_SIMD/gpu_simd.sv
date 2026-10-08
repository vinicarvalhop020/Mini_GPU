`timescale 1ns / 1ps

// Top-level da mini GPU SIMD.
module gpu_simd (
    input  logic        clk,
    input  logic        rst,

    // Interface com o host.
    input  logic [41:0] req_payload,
    input  logic        req_valid,
    output logic        req_ready,
    output logic [31:0] rsp_data,
    output logic        rsp_valid,
    output logic        rsp_error
);

    // Packet Decoder
    logic       decoded_valid;
    logic       decoded_ready;
    logic [1:0] req_type;
    logic [7:0] field_0;
    logic [7:0] field_1;
    logic [7:0] field_2;
    logic [7:0] field_3;
    logic [7:0] field_4;

    // AXI Slave
    logic [7:0]  mem_a_addr;
    logic [31:0] mem_a_wdata;
    logic [31:0] mem_a_rdata;
    logic        mem_a_we;
    logic        mem_a_re;

    // AXI Slave <-> Scheduler
    logic [31:0] cmd_fields;
    logic        cmd_valid;
    logic        cmd_ready;
    logic        cmd_busy;
    logic        cmd_done;

    // Scheduler <-> FSM
    logic [31:0] exec_fields;
    logic        exec_valid;
    logic        exec_ready;
    logic        exec_done;

    // FSM -> Memoria vetorial
    logic [7:0]  mem_b_addr;
    logic [31:0] mem_b_rdata;
    logic        mem_b_we;
    logic        mem_b_re;

    // FSM -> registradores vetoriais e ALU SIMD    
    logic        load_a;
    logic        load_b;
    logic [7:0]  alu_opcode;
    logic [31:0] vector_a;
    logic [31:0] vector_b;
    logic [31:0] alu_result;

    // Sinais de debugging
    logic [1:0] scheduler_debug_state;
    logic [2:0] fsm_debug_state;

    // Recebe o pacote do host e o mantem estavel ate o AXI Slave aceita-lo.
    packet_decoder u_packet_decoder (
        .clk(clk),
        .rst(rst),
        .req_payload(req_payload),
        .req_valid(req_valid),
        .req_ready(req_ready),
        .decoded_valid(decoded_valid),
        .decoded_ready(decoded_ready),
        .req_type(req_type),
        .field_0(field_0),
        .field_1(field_1),
        .field_2(field_2),
        .field_3(field_3),
        .field_4(field_4)
    );

    // Traduz os quatro tipos de pacote para memoria, COMMAND e CONTROL.
    axi_slave u_axi_slave (
        .clk(clk),
        .rst(rst),
        .decoded_valid(decoded_valid),
        .decoded_ready(decoded_ready),
        .req_type(req_type),
        .field_0(field_0),
        .field_1(field_1),
        .field_2(field_2),
        .field_3(field_3),
        .field_4(field_4),
        .rsp_valid(rsp_valid),
        .rsp_error(rsp_error),
        .rsp_data(rsp_data),
        .mem_a_addr(mem_a_addr),
        .mem_a_wdata(mem_a_wdata),
        .mem_a_we(mem_a_we),
        .mem_a_re(mem_a_re),
        .mem_a_rdata(mem_a_rdata),
        .cmd_fields(cmd_fields),
        .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready),
        .cmd_busy(cmd_busy),
        .cmd_done(cmd_done)
    );

    // Guarda um unico comando e conserva BUSY/DONE para o AXI Slave.
    scheduler u_scheduler (
        .clk(clk),
        .rst(rst),
        .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready),
        .cmd_fields(cmd_fields),
        .exec_valid(exec_valid),
        .exec_ready(exec_ready),
        .exec_fields(exec_fields),
        .exec_done(exec_done),
        .busy(cmd_busy),
        .done(cmd_done),
        .debug_state(scheduler_debug_state)
    );

    // Executa o comando recebido e controla a porta B da memoria.
    fsm u_fsm (
        .clk(clk),
        .rst(rst),
        .exec_valid(exec_valid),
        .exec_ready(exec_ready),
        .exec_fields(exec_fields),
        .mem_b_addr(mem_b_addr),
        .mem_b_we(mem_b_we),
        .mem_b_re(mem_b_re),
        .load_a(load_a),
        .load_b(load_b),
        .alu_opcode(alu_opcode),
        .exec_done(exec_done),
        .debug_state(fsm_debug_state)
    );

    // Porta A e acessada pelo AXI Slave; porta B pela FSM.
    // O resultado da ALU e ligado diretamente ao dado de escrita da porta B.
    dualport_memory u_vector_memory (
        .clk(clk),
        .a_addr(mem_a_addr),
        .b_addr(mem_b_addr),
        .a_wdata(mem_a_wdata),
        .b_wdata(alu_result), // Alu escreve direto na memória.
        .a_we(mem_a_we),
        .b_we(mem_b_we),
        .a_re(mem_a_re),
        .b_re(mem_b_re),
        .a_rdata(mem_a_rdata),
        .b_rdata(mem_b_rdata)
    );

    // Os registradores capturam os operandos retornados pela porta B.
    register_vector u_vector_registers (
        .clk(clk),
        .rst(rst),
        .mem_b_rdata(mem_b_rdata),
        .load_a(load_a),
        .load_b(load_b),
        .vector_a(vector_a),
        .vector_b(vector_b)
    );

    // A ALU recebe os dois vetores e produz o dado escrito pela porta B.
    alu_simd u_alu_simd (
        .vector_a(vector_a),
        .vector_b(vector_b),
        .alu_opcode(alu_opcode),
        .result(alu_result)
    );

endmodule
