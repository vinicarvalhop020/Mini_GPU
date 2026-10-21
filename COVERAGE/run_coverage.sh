#!/usr/bin/env bash
# Roda toda a campanha UVM, une os bancos e abre a GUI do IMC.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."
mkdir -p COVERAGE/logs

tests=(
  gpu_matrix_mul_test
  test_packet_field_extraction
  test_host_backpressure
  test_packet_mem_write
  test_packet_mem_read
  test_packet_command_start
  test_axi_decode
  test_axi_memory_access
  test_gpu_reset
  test_scheduler_handshake
  test_fsm_sequence
  test_gpu_add_end_to_end
  test_gpu_all_ops
  test_gpu_mul_8bit
  test_gpu_back_to_back
  test_gpu_address_corner_cases
  test_gpu_random
)

sim_work=$(mktemp -d /tmp/mini_gpu_cov.XXXXXX)
trap 'rm -rf -- "$sim_work"' EXIT

for test_name in "${tests[@]}"; do
  echo "Executando $test_name"
  xrun -64bit -uvm -define ASSERTIONS \
    -coverage all -covoverwrite \
    -covworkdir COVERAGE -covtest "$test_name" \
    -xmlibdirname "$sim_work/$test_name" \
    -f UVM/gpu/files.f \
    +UVM_TESTNAME="$test_name" \
    -l "COVERAGE/logs/$test_name.log"
done

find COVERAGE -maxdepth 1 -type f -name '*.history' -exec mv -t COVERAGE/logs {} +
imc -64bit -exec COVERAGE/merge_coverage.tcl > COVERAGE/logs/imc_merge.log 2>&1
imc -64bit -gui -load COVERAGE/scope/merged
