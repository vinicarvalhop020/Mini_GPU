`timescale 1ns / 1ps

module packet_decoder_tb;

    localparam logic [41:0] PACKET = {
        2'b10,
        8'hAA,
        8'hBB,
        8'hCC,
        8'hDD,
        8'hEE
    };

    logic        clk;
    logic        rst;
    logic [41:0] req_payload;
    logic        req_valid;
    logic        req_ready;
    logic        decoded_valid;
    logic        decoded_ready;
    logic [1:0]  req_type;
    logic [7:0]  field_0;
    logic [7:0]  field_1;
    logic [7:0]  field_2;
    logic [7:0]  field_3;
    logic [7:0]  field_4;

    packet_decoder uut (
        .clk(clk), .rst(rst),
        .req_payload(req_payload), .req_valid(req_valid), .req_ready(req_ready),
        .decoded_valid(decoded_valid), .decoded_ready(decoded_ready),
        .req_type(req_type),
        .field_0(field_0), .field_1(field_1), .field_2(field_2),
        .field_3(field_3), .field_4(field_4)
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
        req_payload = '0;
        req_valid = 1'b0;
        decoded_ready = 1'b0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        #1;
        check(req_ready && !decoded_valid, "decoder pronto apos reset");

        // Host envia TYPE=10 e cinco campos conhecidos.
        @(negedge clk);
        req_payload = PACKET;
        req_valid = 1'b1;
        @(posedge clk);
        #1;
        check(decoded_valid && !req_ready, "pacote aceito pelo decoder");
        check(req_type == 2'b10, "TYPE fatiado corretamente");
        check(field_0 == 8'hAA, "FIELD_0 fatiado corretamente");
        check(field_1 == 8'hBB, "FIELD_1 fatiado corretamente");
        check(field_2 == 8'hCC, "FIELD_2 fatiado corretamente");
        check(field_3 == 8'hDD, "FIELD_3 fatiado corretamente");
        check(field_4 == 8'hEE, "FIELD_4 fatiado corretamente");

        // Decoder AXI aceita o pacote e libera o Host para a proxima requisicao.
        @(negedge clk);
        req_valid = 1'b0;
        decoded_ready = 1'b1;
        @(posedge clk);
        #1;
        check(!decoded_valid && req_ready, "pacote entregue ao decoder AXI");

        $display("packet_decoder_tb: todos os testes passaram.");
        $finish;
    end

endmodule
