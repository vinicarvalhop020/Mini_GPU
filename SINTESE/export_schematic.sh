#!/usr/bin/env bash
# Gera SINTESE/schematics/alu_simd_schematic.gif.
set -euo pipefail

synth_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
genus_bin="${GENUS_BIN:-/tools/cadence/DDI221/bin/genus}"

if [[ ! -x "$genus_bin" ]]; then
    echo "Genus nao encontrado em: $genus_bin" >&2
    exit 1
fi

if [[ ! -f "$synth_dir/netlist/gpu_simd.v" ]]; then
    echo "Netlist nao encontrada. Execute ./SINTESE/run_synthesis.sh primeiro." >&2
    exit 1
fi

mkdir -p "$synth_dir"/{schematics,work}
cd "$synth_dir/work"
"$genus_bin" -files "$synth_dir/scripts/export_alu_schematic.tcl"
