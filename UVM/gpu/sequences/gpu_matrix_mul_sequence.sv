`include "uvm_macros.svh"
import uvm_pkg::*;

// Programa de host direcionado para calcular C = A x B, com matrizes 4x4.
// A GPU usa vetores de quatro lanes, portanto cada linha de B e de C ocupa
// uma palavra da memoria vetorial; cada escalar de A e gravado em broadcast.
class gpu_matrix_mul_sequence extends uvm_sequence #(gpu_item);
    `uvm_object_utils(gpu_matrix_mul_sequence)

    localparam logic [7:0] OP_ADD = 8'h01;
    localparam logic [7:0] OP_MUL = 8'h03;

    localparam logic [7:0] B_BASE = 8'h00;
    localparam logic [7:0] A_BASE = 8'h10;
    localparam logic [7:0] TEMP   = 8'h20;
    localparam logic [7:0] C_BASE = 8'h30;

    logic [7:0] matrix_a [0:3][0:3];
    logic [7:0] matrix_b [0:3][0:3];
    logic [31:0] matrix_c [0:3];

    function new(string name = "gpu_matrix_mul_sequence");
        super.new(name);

        matrix_a[0][0] = 1; matrix_a[0][1] = 2;
        matrix_a[0][2] = 3; matrix_a[0][3] = 4;
        matrix_a[1][0] = 0; matrix_a[1][1] = 1;
        matrix_a[1][2] = 2; matrix_a[1][3] = 3;
        matrix_a[2][0] = 4; matrix_a[2][1] = 3;
        matrix_a[2][2] = 2; matrix_a[2][3] = 1;
        matrix_a[3][0] = 1; matrix_a[3][1] = 0;
        matrix_a[3][2] = 1; matrix_a[3][3] = 0;

        matrix_b[0][0] = 1; matrix_b[0][1] = 2;
        matrix_b[0][2] = 0; matrix_b[0][3] = 1;
        matrix_b[1][0] = 0; matrix_b[1][1] = 1;
        matrix_b[1][2] = 2; matrix_b[1][3] = 0;
        matrix_b[2][0] = 1; matrix_b[2][1] = 0;
        matrix_b[2][2] = 1; matrix_b[2][3] = 2;
        matrix_b[3][0] = 2; matrix_b[3][1] = 1;
        matrix_b[3][2] = 0; matrix_b[3][3] = 1;
    endfunction

    // Envia um pacote e retorna a resposta preenchida pelo driver.
    task automatic send_packet(
        input  gpu_packet_type_e packet_type,
        input  logic [7:0]       field_0,
        input  logic [7:0]       field_1,
        input  logic [7:0]       field_2,
        input  logic [7:0]       field_3,
        input  logic [7:0]       field_4,
        output logic [31:0]      response_data
    );
        gpu_item request;

        request = gpu_item::type_id::create("request");
        start_item(request);

        request.packet_type = packet_type;
        request.field_0     = field_0;
        request.field_1     = field_1;
        request.field_2     = field_2;
        request.field_3     = field_3;
        request.field_4     = field_4;

        finish_item(request);
        response_data = request.rsp_data;
    endtask

    task automatic write_vector(
        input logic [7:0]  address,
        input logic [31:0] vector_data
    );
        logic [31:0] response_data;

        send_packet(GPU_MEM_WRITE, address,
                    vector_data[31:24], vector_data[23:16],
                    vector_data[15:8],  vector_data[7:0], response_data);
    endtask

    task automatic execute_operation(
        input logic [7:0] opcode,
        input logic [7:0] src_a,
        input logic [7:0] src_b,
        input logic [7:0] dst
    );
        logic [31:0] response_data;

        send_packet(GPU_COMMAND, 8'h00, opcode, src_a, src_b, dst,
                    response_data);
        send_packet(GPU_START, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
                    response_data);
    endtask

    virtual task body();
        logic [31:0] response_data;

        `uvm_info("GPU_MATRIX", "Gravando A e B na memoria vetorial", UVM_LOW)

        // B e armazenada por linhas, pois cada linha ja e um vetor SIMD.
        for (int k = 0; k < 4; k++) begin
            write_vector(B_BASE + k,
                         {matrix_b[k][0], matrix_b[k][1],
                          matrix_b[k][2], matrix_b[k][3]});
        end

        // Cada A[i][k] e replicado nas quatro lanes para multiplicar B[k].
        for (int i = 0; i < 4; i++) begin
            for (int k = 0; k < 4; k++) begin
                write_vector(A_BASE + (i * 4) + k,
                             {4{matrix_a[i][k]}});
            end
        end

        `uvm_info("GPU_MATRIX", "Executando C = A x B", UVM_LOW)

        for (int i = 0; i < 4; i++) begin
            // C[i] = A[i][0] * B[0].
            execute_operation(OP_MUL, A_BASE + (i * 4), B_BASE,
                              C_BASE + i);

            // C[i] = C[i] + A[i][k] * B[k], para k de 1 a 3.
            for (int k = 1; k < 4; k++) begin
                execute_operation(OP_MUL, A_BASE + (i * 4) + k,
                                  B_BASE + k, TEMP);
                execute_operation(OP_ADD, C_BASE + i, TEMP, C_BASE + i);
            end
        end

        // Leitura final. A comparacao com o resultado esperado sera tarefa
        // do scoreboard quando ele for introduzido.
        for (int i = 0; i < 4; i++) begin
            send_packet(GPU_MEM_READ, C_BASE + i, 8'h00, 8'h00,
                        8'h00, 8'h00, response_data);
            matrix_c[i] = response_data;
            `uvm_info("GPU_MATRIX",
                      $sformatf("C[%0d] observada = %08h", i, matrix_c[i]),
                      UVM_LOW)
        end
    endtask

endclass
