`include "uvm_macros.svh"
import uvm_pkg::*;

// O scoreboard recebe as transacoes publicadas pelo monitor e confere os resultados esperados
// A ideia do scoreboard pode ser comparada com a do GPU RTL.
// Ele opera como uma sombra do GPU rtl escrevendo e lendo em uma memoria local.
// GPU RTL:         recebe pacote → altera memória real → responde
// Scoreboard:      recebe pacote → altera memória esperada → compara resposta
class gpu_scoreboard extends uvm_component;
    `uvm_component_utils(gpu_scoreboard)

    uvm_analysis_imp #(gpu_item, gpu_scoreboard) analysis_export;

    localparam logic [7:0] OP_ADD = 8'h01;
    localparam logic [7:0] OP_SUB = 8'h02;
    localparam logic [7:0] OP_MUL = 8'h03;
    localparam logic [7:0] OP_DIV = 8'h04;

    // Memoria local que para o scoreboard armazena os valores esperados
    logic [63:0] expected_memory [0:255];

    // variavel para salvar o ultimo comando esperado
    logic [31:0] expected_command;
    bit          command_is_valid;

    // Contadores para transacoes verificadas, leituras verificadas e divergencias encontradas
    int unsigned checked_transactions;
    int unsigned checked_reads;
    int unsigned mismatches;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Inicializa a memoria esperada e os contadores com valores padrao
        foreach (expected_memory[address])
            expected_memory[address] = 64'b0; // zera a memoria esperada

        expected_command     = 32'b0; // zera o ultimo comando esperado
        command_is_valid     = 1'b0;  // indica que nao ha comando valido
        checked_transactions = 0;     // zera o contador de transacoes verificadas
        checked_reads        = 0;     // zera o contador de leituras verificadas
        mismatches           = 0;     // zera o contador de divergencias encontradas
    endfunction

    // Reproduz uma operacao SIMD de quatro lanes de 16 bits.
    function automatic logic [63:0] calculate_simd_result(
        input logic [63:0] vector_a,
        input logic [63:0] vector_b,
        input logic [7:0]  opcode
    );
        logic [63:0] result;
        logic signed [15:0] lane_a;
        logic signed [15:0] lane_b;

        result = 64'b0;

        for (int lane = 0; lane < 4; lane++) begin
            // reproduz a operacao SIMD para a lane atual
            lane_a = vector_a[lane*16 +: 16];
            lane_b = vector_b[lane*16 +: 16];

            case (opcode)
                OP_ADD: result[lane*16 +: 16] = lane_a + lane_b;
                OP_SUB: result[lane*16 +: 16] = lane_a - lane_b;
                OP_MUL: result[lane*16 +: 16] = lane_a * lane_b;
                OP_DIV: result[lane*16 +: 16] =
                            (lane_b == 16'sd0) ? 16'sd0 : lane_a / lane_b;
                default: result[lane*16 +: 16] = 16'h0000;
            endcase
        end

        return result;
    endfunction

    // Indica se alguma lane produziu overflow ou tentou dividir por zero.
    function automatic bit calculate_simd_error(
        input logic [63:0] vector_a,
        input logic [63:0] vector_b,
        input logic [7:0]  opcode
    );
        logic signed [15:0] lane_a;
        logic signed [15:0] lane_b;
        logic signed [16:0] sum_full;
        logic signed [16:0] sub_full;
        logic signed [31:0] product_full;

        calculate_simd_error = 1'b0;

        for (int lane = 0; lane < 4; lane++) begin
            lane_a = vector_a[lane*16 +: 16];
            lane_b = vector_b[lane*16 +: 16];

            case (opcode)
                OP_ADD: begin
                    sum_full = lane_a + lane_b;
                    calculate_simd_error |= (lane_a[15] == lane_b[15]) &&
                                            (sum_full[15] != lane_a[15]);
                end
                OP_SUB: begin
                    sub_full = lane_a - lane_b;
                    calculate_simd_error |= (lane_a[15] != lane_b[15]) &&
                                            (sub_full[15] != lane_a[15]);
                end
                OP_MUL: begin
                    product_full = $signed({{16{lane_a[15]}}, lane_a}) *
                                   $signed({{16{lane_b[15]}}, lane_b});
                    calculate_simd_error |= (product_full > 32'sd32767) ||
                                            (product_full < -32'sd32768);
                end
                OP_DIV: calculate_simd_error |=
                    (lane_b == 16'sd0) ||
                    ((lane_a == 16'sh8000) && (lane_b == -16'sd1));
                default: calculate_simd_error |= 1'b0;
            endcase
        end
    endfunction

    function void compare_response(
        // Compara a resposta do GPU com os dados esperados
        input gpu_item      transaction,
        input logic [63:0] expected_data,
        input string        operation
    );
        if (transaction.rsp_error) begin
            mismatches++;
            `uvm_error("GPU_SB",
                       $sformatf("%s retornou rsp_error.", operation))
        end

        if (transaction.rsp_data !== expected_data) begin
            mismatches++;
            `uvm_error("GPU_SB",
                       $sformatf("%s: esperado=%016h recebido=%016h",
                                 operation, expected_data,
                                 transaction.rsp_data))
        end else begin
            `uvm_info("GPU_SB",
                      $sformatf("%s conferido: %016h",
                                operation, transaction.rsp_data),
                      UVM_LOW)
        end
    endfunction

    // Chamado automaticamente pelo analysis_export a cada transacao completa
    // publicada pelo monitor.
    function void write(gpu_item transaction);
        logic [7:0]  opcode;
        logic [7:0]  src_a;
        logic [7:0]  src_b;
        logic [7:0]  dst;
        logic [63:0] result;
        bit          expected_error;

        checked_transactions++;
        expected_error = 1'b0;

        case (transaction.packet_type)
            GPU_MEM_WRITE: begin
                expected_memory[transaction.field_0] = {
                    {{8{transaction.field_1[7]}}, transaction.field_1},
                    {{8{transaction.field_2[7]}}, transaction.field_2},
                    {{8{transaction.field_3[7]}}, transaction.field_3},
                    {{8{transaction.field_4[7]}}, transaction.field_4}
                };
                compare_response(transaction, 64'b0, "MEM_WRITE");
            end

            GPU_MEM_READ: begin
                checked_reads++;
                compare_response(
                    transaction,
                    expected_memory[transaction.field_0],
                    $sformatf("MEM_READ endereco=%02h", transaction.field_0)
                );
            end

            GPU_COMMAND: begin
                expected_command = {
                    transaction.field_1, transaction.field_2,
                    transaction.field_3, transaction.field_4
                };
                command_is_valid = 1'b1;
                compare_response(transaction, 64'b0, "GPU_COMMAND");
            end

            GPU_START: begin
                if (!command_is_valid) begin
                    mismatches++;
                    `uvm_error("GPU_SB",
                               "GPU_START observado sem GPU_COMMAND anterior.")
                end else begin
                    opcode = expected_command[31:24];
                    src_a  = expected_command[23:16];
                    src_b  = expected_command[15:8];
                    dst    = expected_command[7:0];

                    result = calculate_simd_result(expected_memory[src_a],
                                                   expected_memory[src_b],
                                                   opcode);
                    expected_error = calculate_simd_error(expected_memory[src_a],
                                                          expected_memory[src_b],
                                                          opcode);
                    expected_memory[dst] = result;
                end

                // A resposta de START precisa indicar que a operacao terminou.
                if ((transaction.rsp_error !== expected_error) ||
                    !transaction.rsp_data[1]) begin
                    mismatches++;
                    `uvm_error("GPU_SB",
                               $sformatf("GPU_START invalido: rsp=%016h erro esperado=%0b recebido=%0b",
                                         transaction.rsp_data,
                                         expected_error,
                                         transaction.rsp_error))
                end else begin
                    `uvm_info("GPU_SB", "GPU_START concluido com DONE=1",
                              UVM_LOW)
                end
            end

            default: begin
                mismatches++;
                `uvm_error("GPU_SB", "Tipo de pacote desconhecido.")
            end
        endcase
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("GPU_SB",
                  $sformatf("Scoreboard: %0d transacoes, %0d leituras, %0d divergencias.",
                            checked_transactions, checked_reads, mismatches),
                  UVM_NONE)
    endfunction

endclass
