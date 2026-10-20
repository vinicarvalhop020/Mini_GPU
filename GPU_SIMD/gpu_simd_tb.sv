`timescale 1ns/1ps

// Teste funcional dos comandos individuais da GPU SIMD.
module gpu_simd_tb;

    localparam logic [1:0] MEM_READ    = 2'b00;
    localparam logic [1:0] MEM_WRITE   = 2'b01;
    localparam logic [1:0] GPU_COMMAND = 2'b10;
    localparam logic [1:0] GPU_START   = 2'b11;

    localparam logic [7:0] OP_ADD = 8'h01;
    localparam logic [7:0] OP_SUB = 8'h02;
    localparam logic [7:0] OP_MUL = 8'h03;
    localparam logic [7:0] OP_DIV = 8'h04;

    localparam logic [7:0] VEC_A   = 8'h00;
    localparam logic [7:0] VEC_B   = 8'h01;
    localparam logic [7:0] DST_ADD = 8'h10;
    localparam logic [7:0] DST_SUB = 8'h11;
    localparam logic [7:0] DST_MUL = 8'h12;
    localparam logic [7:0] DST_DIV = 8'h13;
    localparam logic [7:0] VEC_MAX_A = 8'h02;
    localparam logic [7:0] VEC_MAX_B = 8'h03;
    localparam logic [7:0] DST_MUL_8 = 8'h14;

    logic        clk;
    logic        rst;
    logic [41:0] req_payload;
    logic        req_valid;
    logic        req_ready;
    logic [63:0] rsp_data;
    logic        rsp_valid;
    logic        rsp_error;
    logic [63:0] result_vector;
    logic        last_rsp_error;

    gpu_simd dut (
        .clk        (clk),
        .rst        (rst),
        .req_payload(req_payload),
        .req_valid  (req_valid),
        .req_ready  (req_ready),
        .rsp_data   (rsp_data),
        .rsp_valid  (rsp_valid),
        .rsp_error  (rsp_error)
    );

    always #5 clk = ~clk;

    task automatic check(
        input logic condition,
        input string message
    );
        begin
            if (!condition) begin
                $error("FALHOU: %s", message);
                $fatal(1);
            end
        end
    endtask

    // Interface do host: envia um pacote e aguarda sua resposta.
    task automatic send_packet_and_wait_response(
        input  logic [1:0] packet_type,
        input  logic [7:0] field_0,
        input  logic [7:0] field_1,
        input  logic [7:0] field_2,
        input  logic [7:0] field_3,
        input  logic [7:0] field_4,
        output logic [63:0] response_data,
        input  string operation_name
    );
        integer cycles;
        begin
            @(negedge clk);
            req_payload = {packet_type, field_0, field_1, field_2,
                           field_3, field_4};
            req_valid = 1'b1;

            while (!req_ready)
                @(negedge clk);

            @(posedge clk);
            @(negedge clk);
            req_valid = 1'b0;

            cycles = 0;
            while (!rsp_valid && (cycles < 200)) begin
                @(posedge clk);
                #1;
                cycles = cycles + 1;
            end

            check(rsp_valid, {operation_name, ": timeout esperando rsp_valid"});
            response_data = rsp_data;
            last_rsp_error = rsp_error;
        end
    endtask

    task automatic mem_write_vector(
        input logic [7:0] address,
        input logic [31:0] vector_data
    );
        logic [63:0] response_data;
        begin
            send_packet_and_wait_response(MEM_WRITE, address,
                                          vector_data[31:24],
                                          vector_data[23:16],
                                          vector_data[15:8],
                                          vector_data[7:0],
                                          response_data, "MEM_WRITE");
            check(response_data == 64'b0,
                  "MEM_WRITE retornou dado inesperado");
            check(!last_rsp_error, "MEM_WRITE retornou rsp_error");
        end
    endtask

    task automatic mem_read_vector(
        input  logic [7:0] address,
        output logic [63:0] vector_data
    );
        begin
            send_packet_and_wait_response(MEM_READ, address, 8'b0, 8'b0,
                                          8'b0, 8'b0, vector_data,
                                          "MEM_READ");
            check(!last_rsp_error, "MEM_READ retornou rsp_error");
        end
    endtask

    // Uma operacao e formada por GPU_COMMAND seguido de GPU_START.
    task automatic gpu_operation(
        input logic [7:0] opcode,
        input logic [7:0] src_a,
        input logic [7:0] src_b,
        input logic [7:0] dst,
        input logic       expected_error
    );
        logic [63:0] response_data;
        begin
            send_packet_and_wait_response(GPU_COMMAND, 8'b0, opcode, src_a,
                                          src_b, dst, response_data,
                                          "GPU_COMMAND");
            check(response_data == 64'b0,
                  "GPU_COMMAND retornou dado inesperado");
            check(!last_rsp_error, "GPU_COMMAND retornou rsp_error");

            send_packet_and_wait_response(GPU_START, 8'b0, 8'b0, 8'b0,
                                          8'b0, 8'b0, response_data,
                                          "GPU_START");
            // Bit 1 = DONE e bit 0 = BUSY. Ao responder, a GPU terminou.
            check(response_data == 64'h0000_0000_0000_0002,
                  "GPU_START nao retornou STATUS DONE");
            check(last_rsp_error == expected_error,
                  "GPU_START retornou rsp_error incorreto");
        end
    endtask

    task automatic run_and_check(
        input logic [7:0] opcode,
        input logic [7:0] src_a,
        input logic [7:0] src_b,
        input logic [7:0] dst,
        input logic [63:0] expected,
        input logic        expected_error,
        input string operation_name
    );
        begin
            gpu_operation(opcode, src_a, src_b, dst, expected_error);
            mem_read_vector(dst, result_vector);
            check(result_vector == expected,
                  $sformatf("%s: recebeu %h, esperava %h",
                            operation_name, result_vector, expected));
            $display("[TB] %s: %h", operation_name, result_vector);
        end
    endtask

    initial begin
        clk         = 1'b0;
        rst         = 1'b1;
        req_payload = 42'b0;
        req_valid   = 1'b0;
        last_rsp_error = 1'b0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // A = [10, 20, 30, 40], B = [2, 5, 0, 8].
        // A terceira lane de B permite cobrir DIV por zero.
        mem_write_vector(VEC_A, 32'h0A_14_1E_28);
        mem_write_vector(VEC_B, 32'h02_05_00_08);

        // Confere a carga antes de testar a unidade de execucao.
        mem_read_vector(VEC_A, result_vector);
        check(result_vector == 64'h000A_0014_001E_0028,
              "vetor A nao foi gravado corretamente");
        mem_read_vector(VEC_B, result_vector);
        check(result_vector == 64'h0002_0005_0000_0008,
              "vetor B nao foi gravado corretamente");

        run_and_check(OP_ADD, VEC_A, VEC_B, DST_ADD,
                      64'h000C_0019_001E_0030, 1'b0, "ADD");
        run_and_check(OP_SUB, VEC_A, VEC_B, DST_SUB,
                      64'h0008_000F_001E_0020, 1'b0, "SUB");
        run_and_check(OP_MUL, VEC_A, VEC_B, DST_MUL,
                      64'h0014_0064_0000_0140, 1'b0, "MUL");
        run_and_check(OP_DIV, VEC_A, VEC_B, DST_DIV,
                      64'h0005_0004_0000_0005, 1'b1, "DIV (inclui zero)");

        // Reutiliza o mesmo endereco para confirmar que o destino e sobrescrito.
        run_and_check(OP_MUL, VEC_A, VEC_B, DST_ADD,
                      64'h0014_0064_0000_0140,
                      1'b0, "MUL sobrescrevendo DST_ADD");

        // Quatro produtos -128 x -128 sem truncamento.
        mem_write_vector(VEC_MAX_A, 32'h8080_8080);
        mem_write_vector(VEC_MAX_B, 32'h8080_8080);
        run_and_check(OP_MUL, VEC_MAX_A, VEC_MAX_B, DST_MUL_8,
                      64'h4000_4000_4000_4000,
                      1'b0, "MUL 8 bits: -128 x -128");

        $display("[TB] PASSOU: todos os comandos SIMD foram validados.");
        $finish;
    end

endmodule
