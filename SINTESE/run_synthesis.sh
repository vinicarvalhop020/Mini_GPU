#!/usr/bin/env bash
# Executa a sintese a partir de qualquer diretorio.
set -euo pipefail

synth_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
genus_bin="${GENUS_BIN:-/tools/cadence/DDI221/bin/genus}"

if [[ ! -x "$genus_bin" ]]; then
    echo "Genus nao encontrado em: $genus_bin" >&2
    exit 1
fi

mkdir -p "$synth_dir"/{logs,netlist,reports,work}
cd "$synth_dir/work"

"$genus_bin" -files "$synth_dir/scripts/setup_gpu_simd.tcl" \
    | tee "$synth_dir/logs/genus.log"
