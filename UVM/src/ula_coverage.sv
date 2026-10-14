`include "uvm_macros.svh"
import uvm_pkg::*;

class ula_coverage extends uvm_subscriber #(ula_item);
    `uvm_component_utils(ula_coverage)
    ula_item item;

    // Covergroup para operações e resultados
    covergroup cg_ula;
        // Cobertura das operações
        opr_cp : coverpoint item.opr {
            bins add = {ula_item::OP_ADD};
            bins sub = {ula_item::OP_SUB};
            bins mul = {ula_item::OP_MUL};
            bins div = {ula_item::OP_DIV};
            bins and_op = {ula_item::OP_AND};
            bins or_op  = {ula_item::OP_OR};
            bins not_op = {ula_item::OP_NOT};
        }

        // Cobertura dos operandos.
        // Os bins normais, juntos com os corner cases, cobrem os 32 bits.
        a_val : coverpoint item.a {
            bins zero           = {32'h0000_0000};
            bins one            = {32'h0000_0001};
            bins low            = {[32'h0000_0002:32'h0000_FFFF]};
            bins mid            = {[32'h0001_0000:32'h5555_5554],
                                   [32'h5555_5556:32'h7FFF_FFFF]};
            bins alternating_55 = {32'h5555_5555}; // 5 = 0101
            bins high           = {[32'h8000_0000:32'hAAAA_AAA9], // parte alta
                                   [32'hAAAA_AAAB:32'hFFFF_FFFE]};
            bins alternating_aa = {32'hAAAA_AAAA}; // 10 = 1010
            bins max            = {32'hFFFF_FFFF}; 
        }

        b_val : coverpoint item.b {
            bins zero           = {32'h0000_0000};
            bins one            = {32'h0000_0001};
            bins low            = {[32'h0000_0002:32'h0000_FFFF]};
            bins mid            = {[32'h0001_0000:32'h5555_5554],
                                   [32'h5555_5556:32'h7FFF_FFFF]};
            bins alternating_55 = {32'h5555_5555};
            bins high           = {[32'h8000_0000:32'hAAAA_AAA9],
                                   [32'hAAAA_AAAB:32'hFFFF_FFFE]};
            bins alternating_aa = {32'hAAAA_AAAA};
            bins max            = {32'hFFFF_FFFF};
        }

        // Cobertura dos resultados
        result_cp : coverpoint item.result {
            bins zero     = {0};
            bins non_zero = default;
        }

        // Cobertura do carry/overflow
        carry_cp : coverpoint item.carry_o {
            bins no_carry = {0};
            bins carry    = {1};
        }

        // Cobertura do sinal zero
        zero_cp : coverpoint item.zero {
            bins is_zero    = {1};
            bins not_zero   = {0};
        }

        reset_cp : coverpoint item.rst_n {
            bins asserted   = {0};
            bins deasserted = {1};
        }

        // Carry nao se aplica a operacoes logicas.
        opr_carry_cross : cross opr_cp, carry_cp {
            ignore_bins logical_operations =
                binsof(opr_cp) intersect {ula_item::OP_AND,
                                           ula_item::OP_OR,
                                           ula_item::OP_NOT}
                && binsof(carry_cp);
        }

        // Cross operação × zero
        opr_zero_cross : cross opr_cp, zero_cp;

        // Cada operacao deve ser exercitada com operandos baixos, medios e altos.
        opr_operands_cross : cross opr_cp, a_val, b_val;

    endgroup

    // Construtor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg_ula = new();
        item   = new("item");
    endfunction

    // Método write chamado pelo analysis port
    function void write(ula_item t);
        if(t == null) return;
        item = t;
        cg_ula.sample();
    endfunction


    virtual function void report_phase(uvm_phase phase);
        real coverage = cg_ula.get_coverage();
        `uvm_info("COV", $sformatf("=== COBERTURA FUNCIONAL: %.2f%% ===", coverage), UVM_LOW)
     // $display("CG1 Coverage %.2f%%",cg_ula.cp_player_pts.get_coverage() );
     // $display("CG2 Coverage %.2f%%",cg_ula.cp_dealer_pts.get_coverage() );
     // $display("CG3 Coverage %.2f%%",cg_ula.cp_resultado.get_coverage() );
     // $display("CG4 Coverage %.2f%%",cg_ula.cp_player_bust_trans.get_coverage() );
    endfunction

endclass
