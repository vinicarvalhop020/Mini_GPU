#!/usr/bin/env bash
# Simulacao funcional da netlist sintetizada da Mini GPU.
set -euo pipefail

sim_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$sim_dir/../.." && pwd)"

cell_library="/pdk/gpdk045/gsclib045_svt_v4.7/gsclib045/verilog/slow_vdd1v0_basicCells.v"
netlist="$project_dir/SINTESE/netlist/gpu_simd.v"
testbench="$project_dir/GPU_SIMD/gpu_simd_tb.sv"

if [[ ! -f "$netlist" ]]; then
    echo "Netlist nao encontrada. Execute ./SINTESE/run_synthesis.sh primeiro." >&2
    exit 1
fi

mkdir -p "$sim_dir"/{logs,work}
cd "$sim_dir/work"

# A RTL da GPU nao aparece nesta lista: somente a netlist, a biblioteca
# de celulas que a implementa e o testbench sao compilados.
xrun -64bit -sv -access +rwc -timescale 1ns/1ps \
    "$cell_library" \
    "$netlist" \
    "$testbench" \
    -top gpu_simd_tb \
    -l "$sim_dir/logs/gate_level.log"
