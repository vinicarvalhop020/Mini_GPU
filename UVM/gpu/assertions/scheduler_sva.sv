`ifdef ASSERTIONS

// Verifica regras observaveis do Scheduler sem alterar seu RTL.
module scheduler_sva (
    input logic       clk,
    input logic       rst,
    input logic       cmd_valid,
    input logic       cmd_ready,
    input logic       busy,
    input logic       done,
    input logic [1:0] debug_state
);

    localparam logic [1:0] DISPATCH = 2'b01;
    localparam logic [1:0] EXECUTE  = 2'b10;

    // DONE deve permanecer ativo ate um novo comando ser aceito.
    property p_done_persists_until_command;
        @(posedge clk) disable iff (rst)
            (done && !(cmd_valid && cmd_ready)) |=> done;
    endproperty

    a_done_persists_until_command: assert property (p_done_persists_until_command)
        else $error("[SVA][SCHEDULER] done foi limpo sem novo comando aceito.");

    // Ao aceitar um novo comando em DONE, a proxima etapa inicia o despacho.
    property p_new_command_restarts_scheduler;
        @(posedge clk) disable iff (rst)
            (done && cmd_valid && cmd_ready) |=> (busy && !done);
    endproperty

    a_new_command_restarts_scheduler: assert property (p_new_command_restarts_scheduler)
        else $error("[SVA][SCHEDULER] Novo comando nao reiniciou o Scheduler.");

    // busy so representa os estados ativos da maquina.
    property p_busy_matches_active_states;
        @(posedge clk) disable iff (rst)
            busy |-> (debug_state inside {DISPATCH, EXECUTE});
    endproperty

    a_busy_matches_active_states: assert property (p_busy_matches_active_states)
        else $error("[SVA][SCHEDULER] busy ativo fora de DISPATCH/EXECUTE.");

endmodule

`endif
