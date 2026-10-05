`timescale 1ns / 1ps

interface alu_simd_if #(parameter int LANES = 4);
    logic [LANES*8-1:0] vector_a;
    logic [LANES*8-1:0] vector_b;
    logic [7:0]         alu_opcode;
    logic [LANES*8-1:0] result;
endinterface

module alu_simd #(parameter int LANES = 4)(
    alu_simd_if #(LANES) alu_if
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

    //Cada lane possui sua propria interface e sua propria ALU de 8 bits.
    alu_unit_if alus_simd [LANES-1:0]();

    generate
        for (genvar i = 0; i < LANES; i++) begin : gen_alu_lanes
            alu_unit alu_lane (
                .alu_if(alus_simd[i])
            );
        end
    endgenerate

    always_comb begin
        case (alu_if.alu_opcode)
            ADD:     lane_control = ALU_ADD;
            SUB:     lane_control = ALU_SUB;
            MUL:     lane_control = ALU_MUL;
            DIV:     lane_control = ALU_DIV;
            default: lane_control = 4'h0;
        endcase
    end

    always_comb begin
        for (int i = 0; i < LANES; i++) begin
            alus_simd[i].a           = alu_if.vector_a[i*8 +: 8];
            alus_simd[i].b           = alu_if.vector_b[i*8 +: 8];
            alus_simd[i].alu_control = lane_control;
            alu_if.result[i*8 +: 8] = alus_simd[i].result;
        end
    end
endmodule

