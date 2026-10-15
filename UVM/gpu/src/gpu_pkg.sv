// Pacote que reune todas as classes do ambiente UVM da GPU.
package gpu_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Configuracao e infraestrutura reutilizavel.
    `include "gpu_agent_config.sv"
    `include "gpu_env_config.sv"
    `include "gpu_item.sv"
    `include "gpu_sequencer.sv"
    `include "gpu_driver.sv"
    `include "gpu_monitor.sv"
    `include "gpu_scoreboard.sv"
    `include "gpu_agent.sv"
    `include "gpu_env.sv"

    // Cenarios de estimulo.
    `include "gpu_mem_write_sequence.sv"
    `include "gpu_mem_read_sequence.sv"
    `include "gpu_command_sequence.sv"
    `include "gpu_start_sequence.sv"
    `include "gpu_operation_sequence.sv"
    `include "gpu_matrix_mul_sequence.sv"

    // Testes UVM.
    `include "gpu_base_test.sv"
    `include "gpu_smoke_test.sv"
    `include "gpu_mem_read_test.sv"
    `include "gpu_command_test.sv"
    `include "gpu_start_test.sv"
    `include "gpu_operation_test.sv"
    `include "gpu_matrix_mul_test.sv"

endpackage
