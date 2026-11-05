#!/usr/bin/env bash
# Gera o SDF, quando necessario, e abre a simulacao temporal no SimVision.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"
timing_dir="$project_dir/SIMULACAO_NETLIST/timing"

cell_library="/pdk/gpdk045/gsclib045_svt_v4.7/gsclib045/verilog/slow_vdd1v0_basicCells.v"
netlist="$project_dir/SINTESE/netlist/gpu_simd.v"
testbench="$project_dir/GPU_SIMD/gpu_simd_tb.sv"
sdf_annotation="$timing_dir/sdf_annotation.sv"

if [[ ! -f "$timing_dir/gpu_simd.sdf" ]]; then
    echo "SDF nao encontrado; gerando pelo Genus..."
    "$timing_dir/generate_sdf.sh"
fi

mkdir -p "$timing_dir/logs" "$timing_dir/work"
cd "$timing_dir/work"

echo "Abrindo a netlist com SDF MAXIMUM no SimVision (clock de 50 MHz)..."

xrun -64bit -sv -access +rwc -timescale 1ns/1ps \
    -define CLOCK_HALF_PERIOD=10 \
    "$cell_library" \
    "$netlist" \
    "$testbench" \
    "$sdf_annotation" \
    -top gpu_simd_tb \
    -top sdf_annotation \
    -gui \
    -l "$timing_dir/logs/timing_simvision.log"
