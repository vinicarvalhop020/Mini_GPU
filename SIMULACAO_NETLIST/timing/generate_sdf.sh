#!/usr/bin/env bash
# Gera o SDF a partir da netlist que ja foi sintetizada.
set -euo pipefail

timing_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
genus_bin="${GENUS_BIN:-/tools/cadence/DDI221/bin/genus}"

if [[ ! -x "$genus_bin" ]]; then
    echo "Genus nao encontrado em: $genus_bin" >&2
    exit 1
fi

if [[ ! -f "$timing_dir/../../SINTESE/netlist/gpu_simd.v" ]]; then
    echo "Netlist nao encontrada. Execute a sintese primeiro." >&2
    exit 1
fi

mkdir -p "$timing_dir"/{logs,reports,work}
cd "$timing_dir/work"
"$genus_bin" -no_gui -files "$timing_dir/generate_sdf.tcl" \
    | tee "$timing_dir/logs/generate_sdf.log"
