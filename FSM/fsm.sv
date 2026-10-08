`timescale 1ns / 1ps

module fsm(
    input  logic clk, 
    input  logic rst,

    // Handshake com o Scheduler
    input  logic exec_valid,
    output logic exec_ready,

    // OPCODE, SRCA, SRCB, DST recebido do Scheduler.
    input [31:0] exec_fields,

    // Endereço da porta B da memória.
    output logic [7:0] mem_b_addr,
    // Controles de escrita e leitura da porta B.
    output logic mem_b_we,
    output logic mem_b_re,

    // Habilitações dos registradores vetoriais.
    output logic load_a,
    output logic load_b,

    // Opcode aplicado a ALU SIMD.
    output logic [7:0] alu_opcode,

    // Pulso indicando que a execução foi concluída.
    output logic exec_done,

    // pino de debug para acompanhar os estados da FSM.
    output logic [2:0] debug_state
);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        READ_A = 3'b001,
        LOAD_A = 3'b010,
        READ_B = 3'b011,
        LOAD_B = 3'b100,
        EXECUTE = 3'b101,
        WRITE_RESULT = 3'b110,
        FINISH = 3'b111
    } fsm_state_t;

    fsm_state_t state, next_state;
    logic [31:0] local_exec_fields;
    logic [7:0] opcode;
    logic [7:0] srca;
    logic [7:0] srcb;
    logic [7:0] dst;

    assign opcode = local_exec_fields[31:24];
    assign srca   = local_exec_fields[23:16];
    assign srcb   = local_exec_fields[15:8];
    assign dst    = local_exec_fields[7:0];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            local_exec_fields <= 32'h0000_0000;
        end else if ((state == IDLE) && exec_valid && exec_ready) begin
            local_exec_fields <= exec_fields;
        end
    end


    always_comb begin
        next_state = state;
        case (state)
            IDLE:  if (exec_valid && exec_ready) next_state = READ_A;
            READ_A: next_state = LOAD_A;
            LOAD_A:  next_state = READ_B;
            READ_B:  next_state = LOAD_B;
            LOAD_B:  next_state = EXECUTE;
            EXECUTE: next_state = WRITE_RESULT;
            WRITE_RESULT: next_state = FINISH;
            FINISH:    next_state = IDLE;
            default:   next_state = IDLE;
        endcase
    end

    always_comb begin
        exec_ready  = 1'b0;
        mem_b_we    = 1'b0;
        mem_b_re    = 1'b0;
        mem_b_addr  = 8'h00;
        load_a      = 1'b0;
        load_b      = 1'b0;
        alu_opcode  = 8'b0;
        exec_done   = 1'b0;
        debug_state = state;

    case (state)
            IDLE: begin
                exec_ready = 1'b1;
            end
            READ_A: begin
                mem_b_re = 1'b1;
                mem_b_addr = srca;
            end
            LOAD_A: begin
                load_a = 1'b1;
            end
            READ_B: begin
                mem_b_re = 1'b1;
                mem_b_addr = srcb;
            end
            LOAD_B: begin
                load_b = 1'b1;
            end
            EXECUTE: begin
                alu_opcode = opcode;
            end
            WRITE_RESULT: begin
                alu_opcode = opcode;
                mem_b_we = 1'b1;
                mem_b_addr = dst;
            end
            FINISH: begin
                exec_done = 1'b1;
            end
            default: begin
            end
        endcase
    end
endmodule
