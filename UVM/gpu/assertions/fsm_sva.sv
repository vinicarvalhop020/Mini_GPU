`ifdef ASSERTIONS

// Verifica regras basicas da FSM de execucao SIMD.
module fsm_sva (
    input logic       clk,
    input logic       rst,
    input logic       mem_b_we,
    input logic       mem_b_re,
    input logic       load_a,
    input logic       load_b,
    input logic       exec_done,
    input logic [2:0] debug_state
);

    localparam logic [2:0] IDLE         = 3'b000;
    localparam logic [2:0] READ_A       = 3'b001;
    localparam logic [2:0] READ_B       = 3'b011;
    localparam logic [2:0] WRITE_RESULT = 3'b110;
    localparam logic [2:0] FINISH       = 3'b111;

    property p_done_only_in_finish;
        @(posedge clk) disable iff (rst)
            exec_done |-> (debug_state == FINISH);
    endproperty

    a_done_only_in_finish: assert property (p_done_only_in_finish)
        else $error("[SVA][FSM] exec_done ativo fora de FINISH.");

    property p_finish_asserts_done;
        @(posedge clk) disable iff (rst)
            (debug_state == FINISH) |-> exec_done;
    endproperty

    a_finish_asserts_done: assert property (p_finish_asserts_done)
        else $error("[SVA][FSM] FINISH sem exec_done.");

    property p_finish_returns_to_idle;
        @(posedge clk) disable iff (rst)
            (debug_state == FINISH) |=> (debug_state == IDLE);
    endproperty

    a_finish_returns_to_idle: assert property (p_finish_returns_to_idle)
        else $error("[SVA][FSM] FINISH nao retornou para IDLE.");

    property p_write_only_in_write_result;
        @(posedge clk) disable iff (rst)
            mem_b_we |-> (debug_state == WRITE_RESULT);
    endproperty

    a_write_only_in_write_result: assert property (p_write_only_in_write_result)
        else $error("[SVA][FSM] Escrita da memoria fora de WRITE_RESULT.");

    property p_read_only_in_read_states;
        @(posedge clk) disable iff (rst)
            mem_b_re |-> (debug_state inside {READ_A, READ_B});
    endproperty

    a_read_only_in_read_states: assert property (p_read_only_in_read_states)
        else $error("[SVA][FSM] Leitura da memoria fora de READ_A/READ_B.");

    property p_register_loads_are_exclusive;
        @(posedge clk) disable iff (rst)
            !(load_a && load_b);
    endproperty

    a_register_loads_are_exclusive: assert property (p_register_loads_are_exclusive)
        else $error("[SVA][FSM] load_a e load_b ativos no mesmo ciclo.");

    property p_memory_port_b_is_not_reading_and_writing;
        @(posedge clk) disable iff (rst)
            !(mem_b_we && mem_b_re);
    endproperty

    a_memory_port_b_is_not_reading_and_writing: assert property (p_memory_port_b_is_not_reading_and_writing)
        else $error("[SVA][FSM] Porta B tentou ler e escrever simultaneamente.");

endmodule

`endif
