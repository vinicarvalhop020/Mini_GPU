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

## Suite documentada

Os testes rastreaveis do plano de verificacao ficam em
`UVM/gpu/tests/tests_documented`. Para executar qualquer teste UVM dessa
suite, substitua `<teste>` pelo nome listado no README da pasta:

```bash
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=<teste> -run -exit
```

Exemplo:

```bash
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_all_ops -run -exit
```

A interface interna usada pelos testes de protocolo, Scheduler e FSM e ligada
com `bind`: ela observa sinais internos, mas nao altera o RTL.

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

## Scoreboard

O ambiente inclui `gpu_scoreboard`. Ele recebe as transacoes completas do
monitor, mantem uma memoria vetorial de referencia e reproduz ADD, SUB, MUL e
DIV em quatro lanes. Cada `MEM_READ` compara automaticamente a resposta da
GPU com o valor esperado. Portanto, o teste de matriz tambem valida os valores
finais de `C`, nao apenas o envio dos pacotes.

Esta etapa ainda nao inclui coverage. Os testes exercitam o fluxo UVM e o
scoreboard aponta divergencias como erros UVM.
