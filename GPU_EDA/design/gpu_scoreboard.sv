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
    logic [31:0] expected_memory [0:255];

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
            expected_memory[address] = 32'b0; // zera a memoria esperada

        expected_command     = 32'b0; // zera o ultimo comando esperado
        command_is_valid     = 1'b0;  // indica que nao ha comando valido
        checked_transactions = 0;     // zera o contador de transacoes verificadas
        checked_reads        = 0;     // zera o contador de leituras verificadas
        mismatches           = 0;     // zera o contador de divergencias encontradas
    endfunction

    // Reproduz uma operacao SIMD de quatro lanes de 8 bits.
    function automatic logic [31:0] calculate_simd_result(
        input logic [31:0] vector_a,
        input logic [31:0] vector_b,
        input logic [7:0]  opcode
    );
        logic [31:0] result; // resultado da operacao SIMD
        logic [7:0]  lane_a; // valor da lane (32 bits em que cada numero ocupa 8 bits) do vetor A
        logic [7:0]  lane_b; // valor da lane do vetor B

        result = 32'b0; // zera o resultado da operacao SIMD

        for (int lane = 0; lane < 4; lane++) begin
            // reproduz a operacao SIMD para a lane atual
            // cada loop faz o calculo de 8 bits
            lane_a = vector_a[lane*8 +: 8];
            lane_b = vector_b[lane*8 +: 8];

            case (opcode)
                OP_ADD: result[lane*8 +: 8] = lane_a + lane_b;
                OP_SUB: result[lane*8 +: 8] = lane_a - lane_b;
                OP_MUL: result[lane*8 +: 8] = lane_a * lane_b;
                OP_DIV: result[lane*8 +: 8] =
                            (lane_b == 8'h00) ? 8'h00 : lane_a / lane_b;
                default: result[lane*8 +: 8] = 8'h00;
            endcase
        end

        return result;
    endfunction

    function void compare_response(
        // Compara a resposta do GPU com os dados esperados
        input gpu_item      transaction,
        input logic [31:0] expected_data,
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
                       $sformatf("%s: esperado=%08h recebido=%08h",
                                 operation, expected_data,
                                 transaction.rsp_data))
        end else begin
            `uvm_info("GPU_SB",
                      $sformatf("%s conferido: %08h",
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
        logic [31:0] result;

        checked_transactions++;

        case (transaction.packet_type)
            GPU_MEM_WRITE: begin
                expected_memory[transaction.field_0] = {
                    transaction.field_1, transaction.field_2,
                    transaction.field_3, transaction.field_4
                };
                compare_response(transaction, 32'b0, "MEM_WRITE");
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
                compare_response(transaction, 32'b0, "GPU_COMMAND");
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
                    expected_memory[dst] = result;
                end

                // A resposta de START precisa indicar que a operacao terminou.
                if (transaction.rsp_error || !transaction.rsp_data[1]) begin
                    mismatches++;
                    `uvm_error("GPU_SB",
                               $sformatf("GPU_START sem DONE: rsp=%08h err=%0b",
                                         transaction.rsp_data,
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
