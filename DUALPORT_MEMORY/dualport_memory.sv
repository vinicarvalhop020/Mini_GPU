`timescale 1ns / 1ps

interface dualport_mem_if #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
);
    logic                  clk;
    logic [ADDR_WIDTH-1:0] a_addr;
    logic [ADDR_WIDTH-1:0] b_addr;
    logic [DATA_WIDTH-1:0] a_wdata;
    logic [DATA_WIDTH-1:0] b_wdata;
    logic                  a_we;
    logic                  b_we;
    logic                  a_re;
    logic                  b_re;
    logic [DATA_WIDTH-1:0] a_rdata;
    logic [DATA_WIDTH-1:0] b_rdata;
endinterface

module dualport_memory #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    dualport_mem_if #(ADDR_WIDTH, DATA_WIDTH) intf
);

    localparam int NUM_ADDRS = 2 ** ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:NUM_ADDRS-1];


    always_ff @(posedge intf.clk) begin
        if (intf.a_re)
            intf.a_rdata <= mem[intf.a_addr];

        if (intf.b_re)
            intf.b_rdata <= mem[intf.b_addr];

        if (intf.a_we)
            mem[intf.a_addr] <= intf.a_wdata;

        if (intf.b_we)
            mem[intf.b_addr] <= intf.b_wdata;
    end

endmodule
