// Ponto de entrada para o painel Design do EDA Playground.
// Todos os arquivos referenciados ficam nesta mesma pasta.

`include "alu_unit.sv"
`include "alu_simd.sv"
`include "dualport_memory.sv"
`include "register_vector.sv"
`include "scheduler.sv"
`include "fsm.sv"
`include "packet_decoder.sv"
`include "axi_slave.sv"
`include "gpu_simd.sv"

`include "gpu_host_if.sv"
`include "gpu_internal_if.sv"
`include "gpu_pkg.sv"

`include "gpu_host_protocol_sva.sv"
`include "scheduler_sva.sv"
`include "fsm_sva.sv"
`include "gpu_bind.sv"
`include "gpu_internal_bind.sv"
