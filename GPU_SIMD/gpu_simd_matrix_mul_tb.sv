`timescale 1ns/1ps

module gpu_simd_matrix_mul_tb;

    localparam logic [1:0] MEM_READ    = 2'b00;
    localparam logic [1:0] MEM_WRITE   = 2'b01;
    localparam logic [1:0] GPU_COMMAND = 2'b10;
    localparam logic [1:0] GPU_START   = 2'b11;

    localparam logic [7:0] OP_ADD = 8'h01;
    localparam logic [7:0] OP_MUL = 8'h03;

    // Layout da memória vetorial usada por este programa de host.
    localparam logic [7:0] B_BASE = 8'h00;
    localparam logic [7:0] A_BASE = 8'h10;
    localparam logic [7:0] TEMP   = 8'h20;
    localparam logic [7:0] C_BASE = 8'h30;

    logic        clk;
    logic        rst;
    logic [41:0] req_payload;
    logic        req_valid;
    logic        req_ready;
    logic [31:0] rsp_data;
    logic        rsp_valid;
    logic        rsp_error;

    logic [7:0] matrix_a [0:3][0:3];
    logic [7:0] matrix_b [0:3][0:3];
    logic [7:0] matrix_c [0:3][0:3];

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

    // Envia um pacote e espera a resposta correspondente do AXI simplificado.
    task automatic send_packet_and_wait_response(
        input  logic [1:0] packet_type,
        input  logic [7:0] field_0,
        input  logic [7:0] field_1,
        input  logic [7:0] field_2,
        input  logic [7:0] field_3,
        input  logic [7:0] field_4,
        output logic [31:0] response_data,
        input  string operation_name
    );
        integer cycles;
        begin
            // Mantém valid até o packet decoder aceitar a requisição.
            @(negedge clk);
            req_payload = {packet_type, field_0, field_1, field_2,
                           field_3, field_4};
            req_valid   = 1'b1;

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
            check(!rsp_error, {operation_name, ": rsp_error foi ativado"});
            response_data = rsp_data;
        end
    endtask

    task automatic mem_write_vector(
        input logic [7:0] address,
        input logic [7:0] lane_0,
        input logic [7:0] lane_1,
        input logic [7:0] lane_2,
        input logic [7:0] lane_3
    );
        logic [31:0] response_data;
        begin
            send_packet_and_wait_response(MEM_WRITE, address, lane_0, lane_1,
                                          lane_2, lane_3, response_data,
                                          "MEM_WRITE");
            check(response_data == 32'b0, "MEM_WRITE retornou dado inesperado");
        end
    endtask

    task automatic mem_read_vector(
        input  logic [7:0] address,
        output logic [31:0] vector_data
    );
        begin
            send_packet_and_wait_response(MEM_READ, address, 8'b0, 8'b0,
                                          8'b0, 8'b0, vector_data,
                                          "MEM_READ");
        end
    endtask

    // Programa o scheduler e aguarda a execução completa de uma instrução SIMD.
    task automatic gpu_operation(
        input logic [7:0] opcode,
        input logic [7:0] src_a,
        input logic [7:0] src_b,
        input logic [7:0] dst
    );
        logic [31:0] response_data;
        begin
            send_packet_and_wait_response(GPU_COMMAND, 8'b0, opcode, src_a,
                                          src_b, dst, response_data,
                                          "GPU_COMMAND");
            check(response_data == 32'b0,
                  "GPU_COMMAND retornou dado inesperado");

            send_packet_and_wait_response(GPU_START, 8'b0, 8'b0, 8'b0,
                                          8'b0, 8'b0, response_data,
                                          "GPU_START");
            check(response_data == 32'h0000_0002,
                  "GPU_START nao retornou STATUS DONE");
        end
    endtask

    integer i;
    integer j;
    integer k;
    integer sum;
    logic [31:0] result_vector;

    initial begin
        clk         = 1'b0;
        rst         = 1'b1;
        req_payload = 42'b0;
        req_valid   = 1'b0;

        // A = [ [1,2,3,4], [0,1,2,3], [4,3,2,1], [1,0,1,0] ]
        matrix_a[0][0] = 1; matrix_a[0][1] = 2;
        matrix_a[0][2] = 3; matrix_a[0][3] = 4;
        matrix_a[1][0] = 0; matrix_a[1][1] = 1;
        matrix_a[1][2] = 2; matrix_a[1][3] = 3;
        matrix_a[2][0] = 4; matrix_a[2][1] = 3;
        matrix_a[2][2] = 2; matrix_a[2][3] = 1;
        matrix_a[3][0] = 1; matrix_a[3][1] = 0;
        matrix_a[3][2] = 1; matrix_a[3][3] = 0;

        // B = [ [1,2,0,1], [0,1,2,0], [1,0,1,2], [2,1,0,1] ]
        matrix_b[0][0] = 1; matrix_b[0][1] = 2;
        matrix_b[0][2] = 0; matrix_b[0][3] = 1;
        matrix_b[1][0] = 0; matrix_b[1][1] = 1;
        matrix_b[1][2] = 2; matrix_b[1][3] = 0;
        matrix_b[2][0] = 1; matrix_b[2][1] = 0;
        matrix_b[2][2] = 1; matrix_b[2][3] = 2;
        matrix_b[3][0] = 2; matrix_b[3][1] = 1;
        matrix_b[3][2] = 0; matrix_b[3][3] = 1;

        // Modelo de referência C = A x B, calculado pelo testbench.
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                sum = 0;
                for (k = 0; k < 4; k = k + 1)
                    sum = sum + matrix_a[i][k] * matrix_b[k][j];
                matrix_c[i][j] = sum[7:0];
            end
        end

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        $display("[TB] Gravando matrizes A e B na memoria vetorial...");
        for (k = 0; k < 4; k = k + 1)
            mem_write_vector(B_BASE + k, matrix_b[k][0], matrix_b[k][1],
                             matrix_b[k][2], matrix_b[k][3]);

        // Cada escalar de A e replicado nas quatro lanes.
        for (i = 0; i < 4; i = i + 1) begin
            for (k = 0; k < 4; k = k + 1)
                mem_write_vector(A_BASE + (i * 4) + k,
                                 matrix_a[i][k], matrix_a[i][k],
                                 matrix_a[i][k], matrix_a[i][k]);
        end

        // Confere o caminho host -> decoder -> AXI -> porta A da memoria
        // antes de iniciar os comandos da GPU.
        mem_read_vector(B_BASE, result_vector);
        check(result_vector == {matrix_b[0][0], matrix_b[0][1],
                                matrix_b[0][2], matrix_b[0][3]},
              "B[0] nao foi gravada corretamente na memoria vetorial");
        mem_read_vector(A_BASE, result_vector);
        check(result_vector == {matrix_a[0][0], matrix_a[0][0],
                                matrix_a[0][0], matrix_a[0][0]},
              "A[0][0] broadcast nao foi gravado corretamente");

        $display("[TB] Executando C = A x B com operacoes SIMD...");
        for (i = 0; i < 4; i = i + 1) begin
            // Primeira parcela: C[i] = A[i][0] * B[0].
            gpu_operation(OP_MUL, A_BASE + (i * 4), B_BASE, C_BASE + i);

            // Demais parcelas: TEMP = A[i][k] * B[k]; C[i] += TEMP.
            for (k = 1; k < 4; k = k + 1) begin
                gpu_operation(OP_MUL, A_BASE + (i * 4) + k,
                              B_BASE + k, TEMP);
                gpu_operation(OP_ADD, C_BASE + i, TEMP, C_BASE + i);
            end
        end

        $display("[TB] Lendo e conferindo a matriz C...");
        for (i = 0; i < 4; i = i + 1) begin
            mem_read_vector(C_BASE + i, result_vector);
            check(result_vector == {matrix_c[i][0], matrix_c[i][1],
                                    matrix_c[i][2], matrix_c[i][3]},
                  $sformatf("linha %0d de C incorreta: recebeu %h, esperava %h",
                            i, result_vector,
                            {matrix_c[i][0], matrix_c[i][1],
                             matrix_c[i][2], matrix_c[i][3]}));
            $display("[TB] C[%0d] = %0d %0d %0d %0d", i,
                     result_vector[31:24], result_vector[23:16],
                     result_vector[15:8], result_vector[7:0]);
        end

        $display("[TB] PASSOU: multiplicacao de matrizes 4x4 concluida.");
        $finish;
    end

endmodule
