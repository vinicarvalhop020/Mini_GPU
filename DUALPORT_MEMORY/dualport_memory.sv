`timescale 1ns / 1ps

module dualport_memory #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk,     // Clock das duas portas sincrona.
    input  logic [ADDR_WIDTH-1:0] a_addr,  // Endereco da porta A, usada pelo AXI Slave/host.
    input  logic [ADDR_WIDTH-1:0] b_addr,  // Endereco da porta B, usada pela FSM/GPU.
    input  logic [DATA_WIDTH-1:0] a_wdata, // Dado a escrever pela porta A.
    input  logic [DATA_WIDTH-1:0] b_wdata, // Resultado da ALU a escrever pela porta B.
    input  logic                  a_we,    // Habilita escrita da porta A.
    input  logic                  b_we,    // Habilita escrita da porta B.
    input  logic                  a_re,    // Solicita leitura sincrona pela porta A.
    input  logic                  b_re,    // Solicita leitura sincrona pela porta B.
    output logic [DATA_WIDTH-1:0] a_rdata, // Dado lido pela porta A na borda seguinte.
    output logic [DATA_WIDTH-1:0] b_rdata  // Dado lido pela porta B na borda seguinte.
);

    localparam int NUM_ADDRS = 2 ** ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] mem [0:NUM_ADDRS-1];

    // Leitura sincrona read-first. Em duas escritas no mesmo endereco, B vence.
    always_ff @(posedge clk) begin
        if (a_re)
            a_rdata <= mem[a_addr];
        if (b_re)
            b_rdata <= mem[b_addr];
        if (a_we)
            mem[a_addr] <= a_wdata;
        if (b_we)
            mem[b_addr] <= b_wdata;
    end

endmodule
