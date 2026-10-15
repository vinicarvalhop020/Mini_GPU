# Testes rastreaveis do plano de verificacao

Este diretorio contem somente os testes de integracao da `gpu_simd` feitos em
UVM. Os testbenches unitarios permanecem junto de seus respectivos modulos RTL.

Os testes de integracao usam o ambiente UVM e a interface interna ligada por
`bind`. Ela somente observa os sinais de `gpu_simd`; os testes continuam
dirigindo a GPU exclusivamente pelo protocolo do host.

| Teste do plano | Implementacao |
| --- | --- |
| `test_gpu_reset` | UVM: `+UVM_TESTNAME=test_gpu_reset` |
| `test_packet_field_extraction` | UVM: `test_packet_field_extraction` |
| `test_packet_mem_write` | UVM: `test_packet_mem_write` |
| `test_packet_mem_read` | UVM: `test_packet_mem_read` |
| `test_packet_command_start` | UVM: `test_packet_command_start` |
| `test_axi_decode` | UVM: `test_axi_decode` |
| `test_axi_memory_access` | UVM: `test_axi_memory_access` |
| `test_scheduler_handshake` | UVM: `test_scheduler_handshake` e `SCHEDULER/scheduler_tb.sv` |
| `test_fsm_sequence` | UVM: `test_fsm_sequence` e `FSM/fsm_tb.sv` |
| `test_gpu_add_end_to_end` | UVM: `test_gpu_add_end_to_end` |
| `test_gpu_all_ops` | UVM: `test_gpu_all_ops` |
| `gpu_matrix_mul_test` | UVM: `gpu_matrix_mul_test` |
| `test_gpu_back_to_back` | UVM: `test_gpu_back_to_back` |
| `test_gpu_address_corner_cases` | UVM: `test_gpu_address_corner_cases` |
| `test_gpu_random` | UVM: `test_gpu_random` |

Os testes unitarios permanecem fora do top UVM porque precisam dirigir
diretamente portas internas de seus modulos. Um `bind` permite observar
sinais; ele nao substitui um driver para essas portas.
