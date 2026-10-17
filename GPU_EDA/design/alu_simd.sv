`timescale 1ns / 1ps

module alu_simd #(
    parameter int LANES = 4,
    parameter int LANE_WIDTH = 16
)(
    input  logic [LANES*LANE_WIDTH-1:0] vector_a,   // Vetor de entrada A
    input  logic [LANES*LANE_WIDTH-1:0] vector_b,   // Vetor de entrada B
    input  logic [7:0]         alu_opcode, // Opcode SIMD recebido da FSM
    output logic [LANES*LANE_WIDTH-1:0] result // Quatro resultados de 16 bits.
);

    localparam logic [7:0] ADD = 8'h01,
                           SUB = 8'h02,
                           MUL = 8'h03,
                           DIV = 8'h04;

    localparam logic [3:0] ALU_ADD = 4'h1,
                           ALU_SUB = 4'h2,
                           ALU_MUL = 4'h3,
                           ALU_DIV = 4'h4;

    logic [3:0] lane_control;
    logic [LANES*LANE_WIDTH-1:0] lane_result;

    generate
        for (genvar i = 0; i < LANES; i++) begin : gen_alu_lanes
            alu_unit alu_lane (
                .a(vector_a[i*LANE_WIDTH +: LANE_WIDTH]),
                .b(vector_b[i*LANE_WIDTH +: LANE_WIDTH]),
                .alu_control(lane_control),
                .result(lane_result[i*LANE_WIDTH +: LANE_WIDTH]),
                .zero()
            );
        end
    endgenerate

    always_comb begin
        case (alu_opcode)
            ADD:     lane_control = ALU_ADD;
            SUB:     lane_control = ALU_SUB;
            MUL:     lane_control = ALU_MUL;
            DIV:     lane_control = ALU_DIV;
            default: lane_control = 4'h0;
        endcase

        result = lane_result;
    end

endmodule
