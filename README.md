# GPU SIMD — Estrutura do Repositório

```text
GPU/
├── ALU_UNIT/                 # ULA de uma lane: ADD, SUB, MUL e DIV
│   ├── alu_unit.sv
│   └── alu_unit_tb.sv
├── ALU_SIMD/                 # Composição SIMD com quatro lanes da ULA
│   ├── alu_simd.sv
│   └── alu_simd_tb.sv
├── DUALPORT_MEMORY/          # Memória vetorial de duas portas
├── REGISTER_VECTOR/          # Registradores dos operandos vetoriais
├── SCHEDULER/                # Aceita comandos e controla BUSY/DONE
├── FSM/                      # Executa a operação SIMD em etapas
├── PACKET_DECODER/           # Fatia o pacote do host em tipo e campos
├── AXI_SLAVE/                # Interface de host e mapa de memória da GPU
├── GPU_SIMD/                 # Módulo composto que conecta todo o RTL
│   ├── gpu_simd.sv
│   ├── gpu_simd_tb.sv        # Testes diretos dos comandos da GPU
│   └── gpu_simd_matrix_mul_tb.sv
├── docs/                     # Arquitetura, fonte LaTeX e PDF do projeto
├── UVM/
│   ├── README.md             # Como executar os testes UVM com Xcelium
│   └── gpu/
│       ├── src/              # Infraestrutura reutilizável: item, driver,
│       │                     # monitor, agent, environment e scoreboard
│       ├── sequences/        # Cenários que geram transações para a GPU
│       ├── tests/            # Testes UVM selecionados com UVM_TESTNAME
│       ├── assertions/       # SVA e binds de protocolo, Scheduler e FSM
│       ├── tb/               # Top-level do ambiente UVM
│       └── files.f           # Ordem de compilação de RTL + UVM
└── README.md                 # Este guia de organização
```

Os diretórios do nível principal implementam e validam individualmente cada
bloco do RTL. `GPU_SIMD/` reúne esses blocos na GPU completa. Já `UVM/gpu/`
é a camada de verificação: ela reutiliza o RTL da raiz, gera estímulos pelo
protocolo de host, observa as respostas e verifica o comportamento com o
scoreboard e assertions.

## Erros encontrados: (Versão 1.0)

| Nome do teste | O que achou | Solução |
|:--|:--|:--|
| `test_gpu_add_end_to_end` | A primeira requisição era enviada durante a inicialização, quando `rst` ainda podia valer `X`.<br><br>O driver cancelava a escrita do vetor no endereço `0x00`, desalinhando as respostas seguintes. | O driver agora aguarda `rst === 1'b0` antes de dirigir uma requisição.<br><br>Assim, `X` é tratado como reset ainda não liberado. |
| `gpu_matrix_mul_test` | A randomização das matrizes evidenciou que uma lane de resultado com 8 bits não representa o produto completo de dois valores de 8 bits.<br><br>Exemplo: `255 × 255 = 65025`, que precisa de 16 bits. | Em implementação: manter entradas do host em 8 bits e ampliar memória, registradores, ALU SIMD e `rsp_data` para 16 bits por lane (`64` bits por vetor). |
