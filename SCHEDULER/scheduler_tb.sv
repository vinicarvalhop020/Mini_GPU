`timescale 1ns / 1ps

module scheduler_tb;

    localparam logic [31:0] CMD_1 = 32'h01_10_20_30;
    localparam logic [1:0] IDLE     = 2'b00;
    localparam logic [1:0] DISPATCH = 2'b01;
    localparam logic [1:0] EXECUTE  = 2'b10;
    localparam logic [1:0] DONE     = 2'b11;

    logic        clk;
    logic        rst;
    logic        cmd_valid;
    logic        cmd_ready;
    logic [31:0] cmd_fields;
    logic        exec_valid;
    logic        exec_ready;
    logic [31:0] exec_fields;
    logic        exec_done;
    logic        busy;
    logic        done;
    logic [1:0]  debug_state;

    scheduler uut (
        .clk(clk), .rst(rst),
        .cmd_valid(cmd_valid), .cmd_ready(cmd_ready), .cmd_fields(cmd_fields),
        .exec_valid(exec_valid), .exec_ready(exec_ready), .exec_fields(exec_fields),
        .exec_done(exec_done), .busy(busy), .done(done), .debug_state(debug_state)
    );

    always #5 clk = ~clk;

    task automatic check(
        input logic condition,
        input string test_name
    );
        assert (condition)
            else $fatal(1, "Falha: %s", test_name);
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        cmd_valid = 1'b0;
        cmd_fields = '0;
        exec_ready = 1'b0;
        exec_done = 1'b0;

        $monitor("%0t state=%b cmd_v/r=%b/%b exec_v/r=%b/%b busy=%b done=%b",
                 $time, debug_state, cmd_valid, cmd_ready,
                 exec_valid, exec_ready, busy, done);

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        #1;
        check(debug_state == IDLE && cmd_ready && !busy && !done,
              "reset retorna ao estado IDLE");

        @(negedge clk);
        cmd_fields = CMD_1;
        cmd_valid = 1'b1;
        @(posedge clk);
        #1;
        check(debug_state == DISPATCH && exec_valid && busy,
              "comando entra em DISPATCH");
        check(exec_fields == CMD_1, "campos do comando armazenados");

        @(negedge clk);
        cmd_valid = 1'b0;
        exec_ready = 1'b1;
        @(posedge clk);
        #1;
        check(debug_state == EXECUTE && !exec_valid && busy,
              "FSM aceitou o comando");

        @(negedge clk);
        exec_ready = 1'b0;
        exec_done = 1'b1;
        @(posedge clk);
        #1;
        check(debug_state == DONE && done && !busy && cmd_ready,
              "exec_done leva ao estado DONE");

        @(negedge clk);
        exec_done = 1'b0;
        #1;
        check(debug_state == DONE && done,
              "DONE permanece ativo ate um novo comando");

        $display("scheduler_tb: todos os testes passaram.");
        $finish;
    end

endmodule
