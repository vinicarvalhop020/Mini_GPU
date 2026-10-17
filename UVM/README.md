# UVM da GPU SIMD
Um mini guia sobre como executar os testes

## Execucao com Xcelium (`xrun`)

Execute os comandos a partir da raiz do projeto `GPU`.

O arquivo `UVM/gpu/files.f` ja lista o RTL, a interface, o pacote UVM e o
top-level. Execute um teste por simulacao usando `+UVM_TESTNAME`.

## Assertions

As assertions sao opcionais e permanecem fora do RTL. Para habilita-las,
adicione `-define ASSERTIONS` ao comando:

```bash
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_add_end_to_end -run -exit
```

Os checkers iniciais verificam o protocolo de host, regras do Scheduler e
regras da FSM

## Suite documentada

Os testes rastreaveis do plano de verificacao ficam em `UVM/gpu/tests`. Todos
derivam de `gpu_base_test`; esse arquivo e infraestrutura reutilizavel, nao um
teste selecionavel por `UVM_TESTNAME`.

| Teste | O que verifica |
|---|---|
| `gpu_matrix_mul_test` | Programa o host para calcular `C = A x B` para matrizes 4x4. |
| `test_packet_field_extraction` | Extracao de `TYPE` e `FIELD_0..FIELD_4` pelo Packet Decoder. |
| `test_packet_mem_write` | Caminho de escrita: endereco, dado, `mem_a_we` e resposta ao host. |
| `test_packet_mem_read` | Caminho de leitura: `mem_a_re` e resposta da memoria ao host. |
| `test_packet_command_start` | Entrega de `GPU_COMMAND` seguido de `GPU_START` ao Scheduler. |
| `test_axi_decode` | Selecao dos caminhos de memoria e comando pelo AXI Slave. |
| `test_axi_memory_access` | Leitura e escrita nos enderecos `00`, `7F` e `FF`. |
| `test_gpu_reset` | Reset ocioso e durante operacao; retorno da FSM e Scheduler a IDLE. |
| `test_scheduler_handshake` | Estados DISPATCH/EXECUTE/DONE e sinais `BUSY`/`DONE`. |
| `test_fsm_sequence` | Ordem `READ_A` ate `FINISH` e pulsos de controle da FSM. |
| `test_gpu_add_end_to_end` | Soma SIMD completa pelo protocolo do host. |
| `test_gpu_all_ops` | Uma operacao completa para cada opcode suportado. |
| `test_gpu_back_to_back` | Operacoes consecutivas sem sobrescrever resultados anteriores. |
| `test_gpu_address_corner_cases` | Enderecos limites e sobreposicao entre operandos e destino. |
| `test_gpu_random` | Vetores, opcodes e enderecos aleatorios comparados com o modelo de referencia. |

Para executar qualquer teste, substitua `<teste>` por um nome da tabela:

```bash
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=<teste> -run -exit
```

Comandos dos testes da suite:

```bash
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_packet_field_extraction -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_packet_mem_write -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_packet_mem_read -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_packet_command_start -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_axi_decode -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_axi_memory_access -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_reset -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_scheduler_handshake -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_fsm_sequence -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_add_end_to_end -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_all_ops -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_back_to_back -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_address_corner_cases -run -exit
xrun -uvm -define ASSERTIONS -access +rw -f UVM/gpu/files.f +UVM_TESTNAME=test_gpu_random -run -exit
```

A interface interna usada pelos testes de protocolo, Scheduler e FSM e ligada
com `bind`: ela observa sinais internos, mas nao altera o RTL.

## Scoreboard

O ambiente inclui `gpu_scoreboard`. Ele recebe as transacoes completas do
monitor, mantem uma memoria vetorial de referencia e reproduz ADD, SUB, MUL e
DIV em quatro lanes. Cada `MEM_READ` compara automaticamente a resposta da
GPU com o valor esperado. Portanto, o teste de matriz tambem valida os valores
finais de `C`, nao apenas o envio dos pacotes.

Esta etapa ainda nao inclui coverage. Os testes exercitam o fluxo UVM e o
scoreboard aponta divergencias como erros UVM.


## Erros encontrados: (Versão 1.0)

| Nome do teste | O que achou | Solução |
| `test_gpu_add_end_to_end` | A primeira requisição era enviada durante a inicialização, quando `rst` ainda podia valer `X`.<br><br>O driver cancelava a escrita do vetor no endereço `0x00`, desalinhando as respostas seguintes. | O driver agora aguarda `rst === 1'b0` antes de dirigir uma requisição.<br><br>Assim, `X` é tratado como reset ainda não liberado. É necessário executar o teste novamente para confirmar o fluxo completo. |


