`include "uvm_macros.svh"
import uvm_pkg::*;

// exercita toda a ISA pelo protocolo de host.
class gpu_all_ops_sequence extends gpu_base_sequence;
    `uvm_object_utils(gpu_all_ops_sequence)

    localparam logic [7:0] OP_ADD = 8'h01;
    localparam logic [7:0] OP_SUB = 8'h02;
    localparam logic [7:0] OP_MUL = 8'h03;
    localparam logic [7:0] OP_DIV = 8'h04;

    function new(string name = "gpu_all_ops_sequence");
        super.new(name);
    endfunction

    virtual task body();
        logic [63:0] read_data;

        // Inclui overflow, underflow, truncamento de MUL e divisor zero.
        write_vector(8'h00, 32'hFA_01_10_FF);
        write_vector(8'h01, 32'h07_02_00_01);

        execute_operation(OP_ADD, 8'h00, 8'h01, 8'h10);
        read_vector(8'h10, read_data);

        execute_operation(OP_SUB, 8'h00, 8'h01, 8'h11);
        read_vector(8'h11, read_data);

        execute_operation(OP_MUL, 8'h00, 8'h01, 8'h12);
        read_vector(8'h12, read_data);

        execute_operation(OP_DIV, 8'h00, 8'h01, 8'h13);
        read_vector(8'h13, read_data);
    endtask
endclass
