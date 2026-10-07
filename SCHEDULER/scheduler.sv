`timescale 1ns / 1ps

module scheduler (
    input  logic        clk,
    input  logic        rst,
    input  logic        cmd_valid,
    output logic        cmd_ready,
    input  logic [31:0] cmd_fields,
    output logic        exec_valid,
    input  logic        exec_ready,
    output logic [31:0] exec_fields,
    input  logic        exec_done,
    output logic        busy,
    output logic        done,
    output logic [1:0]  debug_state
);

    typedef enum logic [1:0] {
        IDLE     = 2'b00,
        DISPATCH = 2'b01,
        EXECUTE  = 2'b10,
        DONE     = 2'b11
    } fsm_state_t;

    fsm_state_t state, next_state;
    logic [31:0] local_cmd_fields;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            local_cmd_fields <= 32'h0000_0000;
        end else if (((state == IDLE) || (state == DONE)) && cmd_valid && cmd_ready) begin
            local_cmd_fields <= cmd_fields;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:     if (cmd_valid && cmd_ready) next_state = DISPATCH;
            DISPATCH: if (exec_ready)             next_state = EXECUTE;
            EXECUTE:  if (exec_done)              next_state = DONE;
            DONE:     if (cmd_valid && cmd_ready) next_state = DISPATCH;
            default:                              next_state = IDLE;
        endcase
    end

    always_comb begin
        cmd_ready   = 1'b0;
        exec_valid  = 1'b0;
        exec_fields = local_cmd_fields;
        busy        = 1'b0;
        done        = 1'b0;
        debug_state = state;

        case (state)
            IDLE: begin
                cmd_ready = 1'b1;
            end
            DISPATCH: begin
                exec_valid = 1'b1;
                busy       = 1'b1;
            end
            EXECUTE: begin
                busy = 1'b1;
            end
            DONE: begin
                cmd_ready = 1'b1;
                done      = 1'b1;
            end
            default: begin
            end
        endcase
    end

endmodule
