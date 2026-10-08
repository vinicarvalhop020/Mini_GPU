`timescale 1ns / 1ps

module fsm_tb;

    localparam logic [31:0] CMD_1 = 32'h03_12_34_56;

    localparam logic [2:0] IDLE         = 3'b000;
    localparam logic [2:0] READ_A       = 3'b001;
    localparam logic [2:0] LOAD_A       = 3'b010;
    localparam logic [2:0] READ_B       = 3'b011;
    localparam logic [2:0] LOAD_B       = 3'b100;
    localparam logic [2:0] EXECUTE      = 3'b101;
    localparam logic [2:0] WRITE_RESULT = 3'b110;
    localparam logic [2:0] FINISH       = 3'b111;

    logic       clk;
    logic       rst;
    logic       exec_valid;
    logic       exec_ready;
    logic [31:0] exec_fields;
    logic [7:0] mem_b_addr;
    logic       mem_b_we;
    logic       mem_b_re;
    logic       load_a;
    logic       load_b;
    logic [7:0] alu_opcode;
    logic       exec_done;
    logic [2:0] debug_state;

    fsm uut (
        .clk(clk), .rst(rst),
        .exec_valid(exec_valid), .exec_ready(exec_ready), .exec_fields(exec_fields),
        .mem_b_addr(mem_b_addr), .mem_b_we(mem_b_we), .mem_b_re(mem_b_re),
        .load_a(load_a), .load_b(load_b), .alu_opcode(alu_opcode),
        .exec_done(exec_done), .debug_state(debug_state)
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
        exec_valid = 1'b0;
        exec_fields = '0;

        $monitor("%0t state=%b exec_v/r=%b/%b addr=%h we/re=%b/%b load_a/b=%b/%b opcode=%h done=%b",
                 $time, debug_state, exec_valid, exec_ready, mem_b_addr,
                 mem_b_we, mem_b_re, load_a, load_b, alu_opcode, exec_done);

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        #1;
        check(debug_state == IDLE && exec_ready && !exec_done,
              "reset retorna ao estado IDLE");

        // Scheduler entrega: opcode=03, src_a=12, src_b=34 e dst=56.
        @(negedge clk);
        exec_fields = CMD_1;
        exec_valid  = 1'b1;
        @(posedge clk);
        #1;
        check(debug_state == READ_A && mem_b_re && mem_b_addr == 8'h12,
              "READ_A solicita src_a");

        @(negedge clk);
        exec_valid = 1'b0;
        @(posedge clk);
        #1;
        check(debug_state == LOAD_A && load_a && !load_b,
              "LOAD_A captura o primeiro operando");

        @(posedge clk);
        #1;
        check(debug_state == READ_B && mem_b_re && mem_b_addr == 8'h34,
              "READ_B solicita src_b");

        @(posedge clk);
        #1;
        check(debug_state == LOAD_B && load_b && !load_a,
              "LOAD_B captura o segundo operando");

        @(posedge clk);
        #1;
        check(debug_state == EXECUTE && alu_opcode == 8'h03,
              "EXECUTE envia o opcode para a ALU");

        @(posedge clk);
        #1;
        check(debug_state == WRITE_RESULT && mem_b_we && mem_b_addr == 8'h56,
              "WRITE_RESULT escreve no destino");

        @(posedge clk);
        #1;
        check(debug_state == FINISH && exec_done,
              "FINISH gera exec_done");

        @(posedge clk);
        #1;
        check(debug_state == IDLE && exec_ready && !exec_done,
              "FINISH retorna a IDLE apos um ciclo");

        $display("fsm_tb: todos os testes passaram.");
        $finish;
    end

endmodule
