
`timescale 1ns / 1ps

module scheduler_tb;

    localparam logic [31:0] CMD_1 = 32'h01_10_20_30;

    localparam logic [1:0] IDLE     = 2'b00;
    localparam logic [1:0] DISPATCH = 2'b01;
    localparam logic [1:0] EXECUTE  = 2'b10;
    localparam logic [1:0] DONE     = 2'b11;

    scheduler_if sif();

    scheduler uut (
        .sif(sif)
    );

    always #5 sif.clk = ~sif.clk;

    task automatic check(
        input logic condition,
        input string test_name
    );
        assert (condition)
            else $fatal(1, "Falha: %s", test_name);
    endtask

    initial begin
        sif.clk        = 1'b0;
        sif.rst        = 1'b1;
        sif.cmd_valid  = 1'b0;
        sif.cmd_fields = '0;
        sif.exec_ready = 1'b0;
        sif.exec_done  = 1'b0;

        // Mostra o estado da FSM e os sinais principais sempre que um deles mudar.
        $monitor("%0t state=%b cmd_v/r=%b/%b exec_v/r=%b/%b busy=%b done=%b",
                 $time, sif.debug_state, sif.cmd_valid, sif.cmd_ready,
                 sif.exec_valid, sif.exec_ready, sif.busy, sif.done);

        repeat (2) @(posedge sif.clk);
        @(negedge sif.clk);
        sif.rst = 1'b0;
        #1;
        check(sif.debug_state == IDLE && sif.cmd_ready && !sif.busy && !sif.done,
              "reset retorna ao estado IDLE");

        // Envia um comando e verifica o estado de despacho.
        @(negedge sif.clk);
        sif.cmd_fields = CMD_1;
        sif.cmd_valid  = 1'b1;
        @(posedge sif.clk);
        #1;
        check(sif.debug_state == DISPATCH && sif.exec_valid && sif.busy,
              "comando entra em DISPATCH");
        check(sif.exec_fields == CMD_1, "campos do comando armazenados");

        @(negedge sif.clk);
        sif.cmd_valid = 1'b0;
        sif.exec_ready = 1'b1;
        @(posedge sif.clk);
        #1;
        check(sif.debug_state == EXECUTE && !sif.exec_valid && sif.busy,
              "FSM aceitou o comando");

        @(negedge sif.clk);
        sif.exec_ready = 1'b0;
        sif.exec_done  = 1'b1;
        @(posedge sif.clk);
        #1;
        check(sif.debug_state == DONE && sif.done && !sif.busy && sif.cmd_ready,
              "exec_done leva ao estado DONE");

        @(negedge sif.clk);
        sif.exec_done = 1'b0;
        #1;
        check(sif.debug_state == DONE && sif.done,
              "DONE permanece ativo ate um novo comando");

        $display("scheduler_tb: todos os testes passaram.");
        $finish;
    end

endmodule
