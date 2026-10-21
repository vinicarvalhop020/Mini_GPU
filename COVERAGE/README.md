# Coverage da Mini GPU

Esta pasta contém os bancos de cobertura gerados pelo Xcelium.

- `scope/merged/`: banco unificado da campanha; este é o diretório principal para abrir no IMC.
- `scope/<nome_do_teste>/`: banco individual de cada teste UVM.
- `logs/`: logs do Xcelium, histórico de cada execução e relatórios do IMC.

## Executar tudo automaticamente

```bash
./COVERAGE/run_coverage.sh
```

O script executa todos os testes, chama `merge_coverage.tcl` e abre a GUI do IMC ao final.

## Executar a campanha completa

Execute os comandos a partir da raiz `Mini_GPU`:

```bash
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

SIM_WORK=$(mktemp -d /tmp/mini_gpu_cov.XXXXXX)

for test_name in "${tests[@]}"; do
  xrun -64bit -uvm -define ASSERTIONS \
    -coverage all -covoverwrite \
    -covworkdir COVERAGE -covtest "$test_name" \
    -xmlibdirname "$SIM_WORK/$test_name" \
    -f UVM/gpu/files.f \
    +UVM_TESTNAME="$test_name" \
    -l "COVERAGE/logs/$test_name.log"
done

find COVERAGE -maxdepth 1 -type f -name '*.history' -exec mv -t COVERAGE/logs {} +
```

O Xcelium grava um banco `.ucd` por teste em `COVERAGE/scope/`.

## Unir os resultados

Depois dos testes, gere o banco final:

```bash
runs=$(find COVERAGE/scope -mindepth 1 -maxdepth 1 -type d ! -name merged -printf '%p ')
imc -64bit -execcmd "merge $runs -out COVERAGE/scope/merged -overwrite"
```

## Abrir a GUI

```bash
imc -64bit -gui -load COVERAGE/scope/merged
```

Na hierarquia do IMC:

- cobertura RTL: `gpu_top_tb > dut`;
- cobertura funcional UVM: `uvm_pkg > uvm_test_top > env > coverage`.

Na campanha inicial, a cobertura funcional atingiu 100% e a cobertura de código do DUT atingiu 97.72%.
