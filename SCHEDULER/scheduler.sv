`timescale 1ns / 1ps

interface scheduler_if;
    logic clk;
    logic rst;
    logic cmd_valid;
    logic cmd_ready;
    logic [31:0] cmd_fields;
    logic exec_valid;
    logic exec_ready;
    logic [31:0] exec_fields;
    logic exec_done;
    logic busy;
    logic done;
    logic [1:0] debug_state;
endinterface

module scheduler(
    scheduler_if sif
);

    // FSM interna e registrador da unica entrada pendente.
    typedef enum logic [1:0] {
        IDLE     = 2'b00,
        DISPATCH = 2'b01,
        EXECUTE  = 2'b10,
        DONE     = 2'b11
    } fsm_state_t;

    // Loop de estados da FSM
    fsm_state_t state, next_state;
    logic [31:0] local_cmd_fields;

    always_ff @(posedge sif.clk or posedge sif.rst) begin
        if (sif.rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // O comando so e capturado quando o Scheduler esta pronto para aceita-lo
    always_ff @(posedge sif.clk or posedge sif.rst) begin
        if (sif.rst) begin
            local_cmd_fields <= 32'h0000_0000;
        end else if (((state == IDLE) || (state == DONE)) &&
                     sif.cmd_valid && sif.cmd_ready) begin
            local_cmd_fields <= sif.cmd_fields;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (sif.cmd_valid && sif.cmd_ready) begin
                    next_state = DISPATCH;
                end
            end
            DISPATCH: begin
                if (sif.exec_ready) begin
                    next_state = EXECUTE;
                end
            end
            EXECUTE: begin
                if (sif.exec_done) begin
                    next_state = DONE;
                end
            end
            DONE: begin
                if (sif.cmd_valid && sif.cmd_ready) begin
                    next_state = DISPATCH;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    always_comb begin
        sif.cmd_ready   = 1'b0;
        sif.exec_valid  = 1'b0;
        sif.exec_fields = local_cmd_fields;
        sif.busy        = 1'b0;
        sif.done        = 1'b0;
        sif.debug_state = state;

        case (state)
            IDLE: begin
                sif.cmd_ready = 1'b1;
            end
            DISPATCH: begin
                sif.exec_valid = 1'b1;
                sif.busy       = 1'b1;
            end
            EXECUTE: begin
                sif.busy = 1'b1;
            end
            DONE: begin
                sif.cmd_ready = 1'b1;
                sif.done      = 1'b1;
            end
        endcase
    end

endmodule
