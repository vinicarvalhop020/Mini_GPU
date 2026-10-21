#!/usr/bin/env bash
# Simulacao temporal: netlist + modelos de celula + SDF MAXIMUM.
set -euo pipefail

timing_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$timing_dir/../.." && pwd)"

cell_library="/pdk/gpdk045/gsclib045_svt_v4.7/gsclib045/verilog/slow_vdd1v0_basicCells.v"
netlist="$project_dir/SINTESE/netlist/gpu_simd.v"
testbench="$project_dir/GPU_SIMD/gpu_simd_tb.sv"
sdf_annotation="$timing_dir/sdf_annotation.sv"

if [[ ! -f "$timing_dir/gpu_simd.sdf" ]]; then
    echo "SDF nao encontrado. Execute ./SIMULACAO_NETLIST/timing/generate_sdf.sh primeiro." >&2
    exit 1
fi

mkdir -p "$timing_dir"/{logs,work}
cd "$timing_dir/work"

xrun -64bit -sv -access +rwc -timescale 1ns/1ps \
    -define CLOCK_HALF_PERIOD=10 \
    "$cell_library" \
    "$netlist" \
    "$testbench" \
    "$sdf_annotation" \
    -top gpu_simd_tb \
    -top sdf_annotation \
    -l "$timing_dir/logs/timing_sim.log"
