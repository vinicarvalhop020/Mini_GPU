`timescale 1ns / 1ps

module axi_slave_tb;

    localparam logic [1:0] MEM_READ    = 2'b00;
    localparam logic [1:0] MEM_WRITE   = 2'b01;
    localparam logic [1:0] GPU_COMMAND = 2'b10;
    localparam logic [1:0] GPU_START   = 2'b11;

    logic        clk;
    logic        rst;
    logic        decoded_valid;
    logic        decoded_ready;
    logic [1:0]  req_type;
    logic [7:0]  field_0, field_1, field_2, field_3, field_4;
    logic        rsp_valid;
    logic        rsp_error;
    logic [31:0] rsp_data;
    logic [7:0]  mem_a_addr;
    logic [31:0] mem_a_wdata;
    logic        mem_a_we;
    logic        mem_a_re;
    logic [31:0] mem_a_rdata;
    logic [31:0] cmd_fields;
    logic        cmd_valid;
    logic        cmd_ready;
    logic        cmd_busy;
    logic        cmd_done;

    logic [31:0] mem [0:255];

    axi_slave uut (
        .clk(clk), .rst(rst),
        .decoded_valid(decoded_valid), .decoded_ready(decoded_ready),
        .req_type(req_type), .field_0(field_0), .field_1(field_1),
        .field_2(field_2), .field_3(field_3), .field_4(field_4),
        .rsp_valid(rsp_valid), .rsp_error(rsp_error), .rsp_data(rsp_data),
        .mem_a_addr(mem_a_addr), .mem_a_wdata(mem_a_wdata),
        .mem_a_we(mem_a_we), .mem_a_re(mem_a_re), .mem_a_rdata(mem_a_rdata),
        .cmd_fields(cmd_fields), .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready), .cmd_busy(cmd_busy), .cmd_done(cmd_done)
    );

    always #5 clk = ~clk;

    // Modelo minimo da porta A: leitura sincrona e escrita na borda de clock.
    always_ff @(posedge clk) begin
        if (mem_a_we)
            mem[mem_a_addr] <= mem_a_wdata;
        if (mem_a_re)
            mem_a_rdata <= mem[mem_a_addr];
    end

    task automatic check(
        input logic condition,
        input string test_name
    );
        assert (condition)
            else $fatal(1, "Falha: %s", test_name);
    endtask

    task automatic send_packet(
        input logic [1:0] type_in,
        input logic [7:0] f0,
        input logic [7:0] f1,
        input logic [7:0] f2,
        input logic [7:0] f3,
        input logic [7:0] f4
    );
        begin
            @(negedge clk);
            req_type = type_in;
            field_0 = f0;
            field_1 = f1;
            field_2 = f2;
            field_3 = f3;
            field_4 = f4;
            decoded_valid = 1'b1;

            while (!decoded_ready)
                @(negedge clk);

            @(posedge clk);
            @(negedge clk);
            decoded_valid = 1'b0;
        end
    endtask

    task automatic wait_response(
        input logic [31:0] expected_data,
        input string       test_name
    );
        int cycles;
        begin
            cycles = 0;
            while (!rsp_valid && cycles < 20) begin
                @(posedge clk);
                #1;
                cycles++;
            end

            check(rsp_valid, {test_name, ": resposta nao recebida"});
            check(!rsp_error, {test_name, ": rsp_error inesperado"});
            check(rsp_data == expected_data, test_name);
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        decoded_valid = 1'b0;
        req_type = '0;
        field_0 = '0; field_1 = '0; field_2 = '0; field_3 = '0; field_4 = '0;
        mem_a_rdata = '0;
        cmd_ready = 1'b0;
        cmd_busy = 1'b0;
        cmd_done = 1'b0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        #1;
        check(decoded_ready, "AXI pronto apos reset");

        // MEM_WRITE: escreve AABBCCDD no endereco 12.
        send_packet(MEM_WRITE, 8'h12, 8'hAA, 8'hBB, 8'hCC, 8'hDD);
        wait_response(32'h0000_0000, "resposta de MEM_WRITE");
        check(mem[8'h12] == 32'hAABB_CCDD, "MEM_WRITE gravou o vetor correto");

        // MEM_READ: devolve o vetor escrito anteriormente.
        send_packet(MEM_READ, 8'h12, 8'h00, 8'h00, 8'h00, 8'h00);
        wait_response(32'hAABB_CCDD, "resposta de MEM_READ");

        // GPU_COMMAND: configura opcode=03, src_a=12, src_b=34 e dst=56.
        send_packet(GPU_COMMAND, 8'h00, 8'h03, 8'h12, 8'h34, 8'h56);
        wait_response(32'h0000_0000, "resposta de GPU_COMMAND");

        // GPU_START: aguarda o Scheduler aceitar o comando e finalizar.
        send_packet(GPU_START, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);
        while (!cmd_valid) begin
            @(posedge clk);
            #1;
        end
        check(cmd_fields == 32'h0312_3456, "GPU_START enviou o comando configurado");

        @(negedge clk);
        cmd_ready = 1'b1;
        @(negedge clk);
        cmd_ready = 1'b0;

        @(negedge clk);
        cmd_done = 1'b1;
        @(negedge clk);
        cmd_done = 1'b0;

        wait_response(32'h0000_0002, "resposta de GPU_START");

        $display("axi_slave_tb: todos os testes passaram.");
        $finish;
    end

endmodule
