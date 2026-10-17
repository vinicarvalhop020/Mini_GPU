`timescale 1ns / 1ps

module axi_slave (
    input  logic        clk, // Clock
    input  logic        rst, // Reset

    // Handshake com o Packet Decoder
    input  logic        decoded_valid, // Packet Decoder possui um pacote valido.
    output logic        decoded_ready, // AXI Slave aceita os campos do pacote.
    input  logic [1:0]  req_type,      // Tipo do pacote recebido READ, WRITE, GPU_COMMAND, GPU_START.
    input  logic [7:0]  field_0,       // Endereco de memoria ou campo reservado.
    input  logic [7:0]  field_1,       // Lane 0 em MEM_WRITE ou opcode em GPU_COMMAND.
    input  logic [7:0]  field_2,       // Lane 1 em MEM_WRITE ou src_a em GPU_COMMAND.
    input  logic [7:0]  field_3,       // Lane 2 em MEM_WRITE ou src_b em GPU_COMMAND.
    input  logic [7:0]  field_4,       // Lane 3 em MEM_WRITE ou dst em GPU_COMMAND.

    // Resposta ao host. rsp_valid e um pulso de um ciclo
    output logic        rsp_valid, // Resposta ao host esta valida por um ciclo.
    output logic        rsp_error, // Reservado para indicar erro atualmente fica em zero e nao faz nada
    output logic [31:0] rsp_data,  // Leitura de memoria, STATUS (cmd_busy ou cmd_done) ou zero em operacoes sem dado.

    // Porta A da memoria vetorial
    output logic [7:0]  mem_a_addr,  // Endereco para a porta A da memoria vetorial.
    output logic [31:0] mem_a_wdata, // vetor de 32 bits a escrever pela porta A.
    output logic        mem_a_we,    // Habilita escrita pela porta A.
    output logic        mem_a_re,    // Solicita leitura sincrona pela porta A.
    input  logic [31:0] mem_a_rdata, // Dado retornado pela porta A.

    // Handshake com o Scheduler
    output logic [31:0] cmd_fields, // Comando {OPCODE, SRC_A, SRC_B, DST} para o Scheduler.
    output logic        cmd_valid,  // Solicita que o Scheduler aceite cmd_fields.
    input  logic        cmd_ready,  // Scheduler esta pronto para receber um novo comando.
    input  logic        cmd_busy,   // Bit BUSY usado na resposta de STATUS.
    input  logic        cmd_done    // Bit DONE que libera a resposta de GPU_START, a fsm concluiu a execucao e levanta esse pino.
);

    typedef enum logic [3:0] {
        IDLE, // Sem requisicao pendente; aceita um pacote do Packet Decoder.
        DECODE,  // Seleciona o fluxo a partir do TYPE armazenado.
        MEM_WRITE, // Escreve FIELD_1..FIELD_4 no endereco FIELD_0 da porta A.
        MEM_READ_REQ, // Solicita a leitura sincrona de FIELD_0 pela porta A.
        MEM_READ_RSP, // Retorna mem_a_rdata ao host depois da latencia da memoria.
        GPU_COMMAND, // Atualiza command_reg com OPCODE, SRC_A, SRC_B e DST.
        START_CMD, // Mantem cmd_valid ate o Scheduler aceitar command_reg.
        WAIT_DONE, // Aguarda cmd_done, indicando que a FSM concluiu a execucao.
        RESPONSE // Gera rsp_valid por um ciclo para escritas, comando ou GPU_START.
    } axi_state_t;

    // Tipos de requisicao
    localparam logic [1:0] TYPE_MEM_READ    = 2'b00,
                           TYPE_MEM_WRITE   = 2'b01,
                           TYPE_GPU_COMMAND = 2'b10,
                           TYPE_GPU_START   = 2'b11;

    axi_state_t state, next_state;

    // registradores locais para armazenar os campos do pacote decodificado
    logic [1:0]  local_req_type;
    logic [7:0]  local_field_0;
    logic [7:0]  local_field_1;
    logic [7:0]  local_field_2;
    logic [7:0]  local_field_3;
    logic [7:0]  local_field_4;
    logic [31:0] command_reg;
    logic [31:0] rsp_data_reg;

    // loop de mudança de estado da FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            local_req_type <= 2'b00;
            local_field_0  <= 8'b0;
            local_field_1  <= 8'b0;
            local_field_2  <= 8'b0;
            local_field_3  <= 8'b0;
            local_field_4  <= 8'b0;
            command_reg    <= 32'b0;
            rsp_data_reg   <= 32'b0;
        end else begin
            if ((state == IDLE) && decoded_valid && decoded_ready) begin
                local_req_type <= req_type;
                local_field_0  <= field_0;
                local_field_1  <= field_1;
                local_field_2  <= field_2;
                local_field_3  <= field_3;
                local_field_4  <= field_4;
            end

            if (state == GPU_COMMAND) begin
                // captura os campos do comando GPU
                command_reg  <= {local_field_1, local_field_2,
                                 local_field_3, local_field_4};
                rsp_data_reg <= 32'b0;
            end

            if (state == MEM_WRITE) begin
                rsp_data_reg <= 32'b0;
            end

            if ((state == WAIT_DONE) && cmd_done) begin
                // captura o status do comando GPU
                rsp_data_reg <= {30'b0, cmd_done, cmd_busy};
            end
        end
    end

    // Transicoes da requisicao atual.
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (decoded_valid && decoded_ready)
                    next_state = DECODE;
            end

            DECODE: begin
                case (local_req_type)
                    TYPE_MEM_READ:    next_state = MEM_READ_REQ;
                    TYPE_MEM_WRITE:   next_state = MEM_WRITE;
                    TYPE_GPU_COMMAND: next_state = GPU_COMMAND;
                    TYPE_GPU_START:   next_state = START_CMD;
                    default:          next_state = IDLE;
                endcase
            end

            MEM_WRITE:    next_state = RESPONSE;
            MEM_READ_REQ: next_state = MEM_READ_RSP;
            MEM_READ_RSP: next_state = IDLE;
            GPU_COMMAND:  next_state = RESPONSE;

            START_CMD: begin
                if (cmd_ready)
                    next_state = WAIT_DONE;
            end

            WAIT_DONE: begin
                if (cmd_done)
                    next_state = RESPONSE;
            end

            RESPONSE: next_state = IDLE;
            default:  next_state = IDLE;
        endcase
    end

    // Saidas de controle. Valores padrao deixam todos os acessos desativados.
    always_comb begin
        decoded_ready = 1'b0;
        rsp_valid     = 1'b0;
        rsp_error     = 1'b0;
        rsp_data      = rsp_data_reg;

        mem_a_addr    = 8'b0;
        mem_a_wdata   = 32'b0;
        mem_a_we      = 1'b0;
        mem_a_re      = 1'b0;

        cmd_fields    = command_reg;
        cmd_valid     = 1'b0;

        case (state)
            IDLE: begin
                decoded_ready = 1'b1;
            end

            MEM_WRITE: begin
                mem_a_addr  = local_field_0;
                mem_a_wdata = {local_field_1, local_field_2,
                               local_field_3, local_field_4};
                mem_a_we    = 1'b1;
            end

            MEM_READ_REQ: begin
                mem_a_addr = local_field_0;
                mem_a_re   = 1'b1;
            end

            MEM_READ_RSP: begin
                rsp_valid = 1'b1;
                rsp_data  = mem_a_rdata;
            end

            GPU_COMMAND: begin
                // command_reg e atualizado na borda de clock deste estado.
            end

            START_CMD: begin
                cmd_valid = 1'b1;
            end

            RESPONSE: begin
                rsp_valid = 1'b1;
            end

            default: begin
            end
        endcase
    end

endmodule
