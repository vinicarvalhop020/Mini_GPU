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

    // Cenario complementar de multiplicacao de matrizes 4x4.
    `include "gpu_matrix_mul_sequence.sv"

    // Sequences rastreaveis do plano de verificacao.
    `include "gpu_base_sequence.sv"
    `include "gpu_reset_sequence.sv"
    `include "gpu_reset_sequence.sv"
    `include "gpu_mul_8bit_sequence.sv"
    `include "gpu_add_sequence.sv"
    `include "gpu_mem_access_sequence.sv"
    `include "gpu_all_ops_sequence.sv"
    `include "gpu_back_to_back_sequence.sv"
    `include "gpu_address_corners_sequence.sv"
    `include "gpu_random_sequence.sv"

    // Testes UVM.
    `include "gpu_base_test.sv"
    `include "gpu_matrix_mul_test.sv"
    `include "test_gpu_mul_8bit.sv"

    // Testes rastreaveis do plano de verificacao.
    `include "test_packet_field_extraction.sv"
    `include "test_packet_mem_write.sv"
    `include "test_packet_mem_read.sv"
    `include "test_packet_command_start.sv"
    `include "test_axi_decode.sv"
    `include "test_axi_memory_access.sv"
    `include "test_gpu_reset.sv"
    `include "test_scheduler_handshake.sv"
    `include "test_fsm_sequence.sv"
    `include "test_gpu_add_end_to_end.sv"
    `include "test_gpu_all_ops.sv"
    `include "test_gpu_back_to_back.sv"
    `include "test_gpu_address_corner_cases.sv"
    `include "test_gpu_random.sv"

endpackage
