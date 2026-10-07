`timescale 1ns / 1ps

module dualport_memory_tb;

    localparam int ADDR_WIDTH = 8;
    localparam int DATA_WIDTH = 32;

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

    dualport_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .a_addr(a_addr), .b_addr(b_addr),
        .a_wdata(a_wdata), .b_wdata(b_wdata),
        .a_we(a_we), .b_we(b_we),
        .a_re(a_re), .b_re(b_re),
        .a_rdata(a_rdata), .b_rdata(b_rdata)
    );

    always #5 clk = ~clk;

    task automatic write_a(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
        begin
            @(negedge clk);
            a_addr = addr; a_wdata = data; a_we = 1'b1;
            @(negedge clk);
            a_we = 1'b0;
        end
    endtask

    task automatic write_b(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
        begin
            @(negedge clk);
            b_addr = addr; b_wdata = data; b_we = 1'b1;
            @(negedge clk);
            b_we = 1'b0;
        end
    endtask

    task automatic read_a(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] expected_data,
        input string                 test_name
    );
        begin
            @(negedge clk);
            a_addr = addr; a_re = 1'b1;
            @(posedge clk);
            #1;
            assert (a_rdata === expected_data)
                else $fatal(1, "%s: porta A esperava %0h, recebeu %0h",
                            test_name, expected_data, a_rdata);
            @(negedge clk);
            a_re = 1'b0;
        end
    endtask

    task automatic read_b(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] expected_data,
        input string                 test_name
    );
        begin
            @(negedge clk);
            b_addr = addr; b_re = 1'b1;
            @(posedge clk);
            #1;
            assert (b_rdata === expected_data)
                else $fatal(1, "%s: porta B esperava %0h, recebeu %0h",
                            test_name, expected_data, b_rdata);
            @(negedge clk);
            b_re = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        a_addr = '0; b_addr = '0;
        a_wdata = '0; b_wdata = '0;
        a_we = 1'b0; b_we = 1'b0;
        a_re = 1'b0; b_re = 1'b0;

        write_a(8'h00, 32'hDEAD_BEEF);
        read_a(8'h00, 32'hDEAD_BEEF, "escrita e leitura na porta A");
        write_b(8'hFF, 32'hCAFE_BABE);
        read_b(8'hFF, 32'hCAFE_BABE, "escrita e leitura na porta B");
        write_a(8'h42, 32'h1234_5678);
        read_b(8'h42, 32'h1234_5678, "leitura pela porta B de escrita pela A");

        @(negedge clk);
        a_addr = 8'h10; a_wdata = 32'hAAAA_1111; a_we = 1'b1;
        b_addr = 8'hE0; b_wdata = 32'hBBBB_2222; b_we = 1'b1;
        @(negedge clk);
        a_we = 1'b0; b_we = 1'b0;

        read_a(8'h10, 32'hAAAA_1111, "escrita simultanea da porta A");
        read_b(8'hE0, 32'hBBBB_2222, "escrita simultanea da porta B");

        $display("dualport_memory_tb: todos os testes passaram.");
        $finish;
    end

endmodule
