# UVM da GPU SIMD

## Execucao com Xcelium (`xrun`)

Execute os comandos a partir da raiz do projeto `GPU`.

O arquivo `UVM/gpu/files.f` ja lista o RTL, a interface, o pacote UVM e o
top-level. Execute um teste por simulacao usando `+UVM_TESTNAME`.

## Assertions

As assertions sao opcionais e permanecem fora do RTL. Para habilita-las,
adicione `-define ASSERTIONS` ao comando:

```bash
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=gpu_smoke_test -run -exit
```

Os checkers iniciais verificam o protocolo de host, regras do Scheduler e
regras da FSM. Veja `UVM/gpu/assertions/README.md` para o mapeamento.

### Smoke test - MEM_WRITE

```bash
xrun -uvm -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=gpu_smoke_test -run -exit
```

### Escrita seguida de leitura de memoria

```bash
xrun -uvm -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=gpu_mem_read_test -run -exit
```

### Programacao de GPU_COMMAND

```bash
xrun -uvm -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=gpu_command_test -run -exit
```

### GPU_COMMAND seguido de GPU_START

```bash
xrun -uvm -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=gpu_start_test -run -exit
```

### Operacao SIMD completa

```bash
xrun -uvm -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=gpu_operation_test -run -exit
```

### Multiplicacao de matrizes 4x4

```bash
xrun -uvm -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=gpu_matrix_mul_test -run -exit
```

## EDA Playground

No EDA Playground, selecione um simulador com suporte a UVM e coloque, nas
opcoes de execucao, apenas um nome de teste por vez:

```text
+UVM_TESTNAME=gpu_smoke_test
```

## Observacao

Esta etapa ainda nao inclui coverage nem scoreboard. Os testes exercitam o
fluxo UVM e registram as transacoes observadas pelo driver e monitor.
