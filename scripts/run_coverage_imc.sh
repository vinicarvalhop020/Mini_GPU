#!/usr/bin/env bash
# Executa a campanha UVM de cobertura, une os bancos no IMC e abre a GUI.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd "$script_dir/.." && pwd)"

exec "$project_dir/COVERAGE/run_coverage.sh"
