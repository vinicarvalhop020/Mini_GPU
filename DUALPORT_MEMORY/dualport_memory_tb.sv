`timescale 1ns / 1ps

module dualport_memory_tb;

    localparam int ADDR_WIDTH = 8;
    localparam int DATA_WIDTH = 32;

    dualport_mem_if #(ADDR_WIDTH, DATA_WIDTH) intf();

    dualport_memory #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .intf(intf)
    );

    always #5 intf.clk = ~intf.clk;

    task automatic write_a(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
        begin
            @(negedge intf.clk);
            intf.a_addr  = addr;
            intf.a_wdata = data;
            intf.a_we    = 1'b1;
            @(negedge intf.clk);
            intf.a_we    = 1'b0;
        end
    endtask

    task automatic write_b(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data
    );
        begin
            @(negedge intf.clk);
            intf.b_addr  = addr;
            intf.b_wdata = data;
            intf.b_we    = 1'b1;
            @(negedge intf.clk);
            intf.b_we    = 1'b0;
        end
    endtask

    task automatic read_a(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] expected_data,
        input string                 test_name
    );
        begin
            @(negedge intf.clk);
            intf.a_addr = addr;
            intf.a_re   = 1'b1;
            @(posedge intf.clk);
            #1;
            assert (intf.a_rdata === expected_data)
                else $fatal(1, "%s: porta A esperava %0h, recebeu %0h",
                            test_name, expected_data, intf.a_rdata);
            @(negedge intf.clk);
            intf.a_re = 1'b0;
        end
    endtask

    task automatic read_b(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] expected_data,
        input string                 test_name
    );
        begin
            @(negedge intf.clk);
            intf.b_addr = addr;
            intf.b_re   = 1'b1;
            @(posedge intf.clk);
            #1;
            assert (intf.b_rdata === expected_data)
                else $fatal(1, "%s: porta B esperava %0h, recebeu %0h",
                            test_name, expected_data, intf.b_rdata);
            @(negedge intf.clk);
            intf.b_re = 1'b0;
        end
    endtask

    initial begin
        intf.clk     = 1'b0;
        intf.a_addr  = '0;
        intf.b_addr  = '0;
        intf.a_wdata = '0;
        intf.b_wdata = '0;
        intf.a_we    = 1'b0;
        intf.b_we    = 1'b0;
        intf.a_re    = 1'b0;
        intf.b_re    = 1'b0;

        // A porta A escreve e le seu proprio endereco.
        write_a(8'h00, 32'hDEAD_BEEF);
        read_a(8'h00, 32'hDEAD_BEEF, "escrita e leitura na porta A");

        // A porta B escreve e le o ultimo endereco da memoria.
        write_b(8'hFF, 32'hCAFE_BABE);
        read_b(8'hFF, 32'hCAFE_BABE, "escrita e leitura na porta B");

        // As duas portas enxergam a mesma memoria, e nao bancos independentes.
        write_a(8'h42, 32'h1234_5678);
        read_b(8'h42, 32'h1234_5678, "leitura pela porta B de escrita pela A");

        // Acessos simultaneos em enderecos diferentes devem ser independentes.
        @(negedge intf.clk);
        intf.a_addr  = 8'h10;
        intf.a_wdata = 32'hAAAA_1111;
        intf.a_we    = 1'b1;
        intf.b_addr  = 8'hE0;
        intf.b_wdata = 32'hBBBB_2222;
        intf.b_we    = 1'b1;
        @(negedge intf.clk);
        intf.a_we = 1'b0;
        intf.b_we = 1'b0;

        read_a(8'h10, 32'hAAAA_1111, "escrita simultanea da porta A");
        read_b(8'hE0, 32'hBBBB_2222, "escrita simultanea da porta B");

        $display("dualport_memory_tb: todos os testes passaram.");
        $finish;
    end

endmodule
