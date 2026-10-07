`timescale 1ns / 1ps

module dualport_memory #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] a_addr,
    input  logic [ADDR_WIDTH-1:0] b_addr,
    input  logic [DATA_WIDTH-1:0] a_wdata,
    input  logic [DATA_WIDTH-1:0] b_wdata,
    input  logic                  a_we,
    input  logic                  b_we,
    input  logic                  a_re,
    input  logic                  b_re,
    output logic [DATA_WIDTH-1:0] a_rdata,
    output logic [DATA_WIDTH-1:0] b_rdata
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
