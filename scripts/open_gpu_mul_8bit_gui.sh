#!/usr/bin/env bash
# Abre no SimVision o teste UVM da multiplicacao SIMD -128 x -128.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
sim_work="$(mktemp -d /tmp/mini_gpu_mul_8bit.XXXXXX)"

trap 'rm -rf -- "$sim_work"' EXIT

cd "$project_dir"
mkdir -p UVM/gpu/logs

echo "Abrindo test_gpu_mul_8bit no SimVision..."
echo "A sequencia usa 8'h80 nos enderecos 00 e 01 e le o resultado do endereco 10."

xrun -64bit -uvm -define ASSERTIONS -access +rwc \
  -xmlibdirname "$sim_work/xcelium.d" \
  -f UVM/gpu/files.f \
  +UVM_TESTNAME=test_gpu_mul_8bit \
  -gui \
  -l UVM/gpu/logs/test_gpu_mul_8bit_simvision.log
