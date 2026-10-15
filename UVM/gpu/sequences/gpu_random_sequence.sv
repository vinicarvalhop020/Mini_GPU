`include "uvm_macros.svh"
import uvm_pkg::*;

// [GPU_RANDOM]: gera programas validos aleatorios; o scoreboard decide o acerto.
class gpu_random_sequence extends gpu_base_sequence;
    `uvm_object_utils(gpu_random_sequence)

    int unsigned iterations;

    function new(string name = "gpu_random_sequence");
        super.new(name);
        iterations = 20;
    endfunction

    virtual task body();
        logic [7:0]  src_a;
        logic [7:0]  src_b;
        logic [7:0]  dst;
        logic [7:0]  opcode;
        logic [31:0] vector_a;
        logic [31:0] vector_b;
        logic [31:0] read_data;

        for (int index = 0; index < iterations; index++) begin
            assert(std::randomize(src_a, src_b, dst, opcode, vector_a, vector_b)
                   with {
                       src_a != src_b;
                       dst != src_a;
                       dst != src_b;
                       opcode inside {8'h01, 8'h02, 8'h03, 8'h04};
                   })
                else `uvm_fatal("GPU_RANDOM", "Falha ao gerar operacao valida")

            write_vector(src_a, vector_a);
            write_vector(src_b, vector_b);
            execute_operation(opcode, src_a, src_b, dst);
            read_vector(dst, read_data);
        end
    endtask
endclass
