# Simulacao Funcional da Netlist

Esta etapa verifica se a `gpu_simd` sintetizada continua com o comportamento
esperado. A simulacao compila a netlist e os modelos das celulas da tecnologia;
a RTL da GPU nao e compilada.

## Ambiente da simulacao

| Item | Configuracao |
| --- | --- |
| Simulador | Xcelium |
| Projeto verificado | `gpu_simd` |
| Implementacao | `SINTESE/netlist/gpu_simd.v` |
| Biblioteca de celulas | `slow_vdd1v0_basicCells.v` |
| Testbench | `GPU_SIMD/gpu_simd_tb.sv` |
| Clock do testbench | 100 MHz (periodo de 10 ns) |
| Anotacao SDF | Nao utilizada nesta etapa |

Como nao ha SDF, o clock de 100 MHz serve apenas para executar o protocolo do
testbench. Esta simulacao valida funcionalidade apos o mapeamento em celulas,
mas nao valida os atrasos temporais. Para isso, use a etapa
[`../timing`](../timing/README.md).

## Executar

No diretorio raiz da Mini GPU:

```bash
./SIMULACAO_NETLIST/funcionamento/run_netlist_sim.sh
```

## O que foi testado

| Caso | Verificacao feita |
| --- | --- |
| Acesso a memoria | Escrita e leitura dos operandos e dos resultados nas memorias da GPU |
| ADD | Soma SIMD dos operandos carregados na memoria |
| SUB | Subtracao SIMD dos operandos carregados na memoria |
| MUL | Multiplicacao SIMD e armazenamento do resultado |
| DIV com divisor zero | Resultado por lane e sinalizacao de erro esperados pelo protocolo |
| Sobrescrita de destino | Um resultado posterior sobrescreve corretamente o endereco de destino |
| Operacao assinada | Multiplicacao `-128 x -128`, validando o suporte a `int8` |

## Resultado obtido

| Medida | Resultado |
| --- | --- |
| Status | **PASSOU** |
| Tempo final da simulacao | 1526 ns |
| Falhas do testbench | 0 |
| Mensagem final | `[TB] PASSOU: todos os comandos SIMD foram validados.` |

## Artefatos

| Arquivo ou diretorio | Conteudo |
| --- | --- |
| `run_netlist_sim.sh` | Script que compila e executa a simulacao gate-level |
| `work/` | Diretorio temporario de compilacao do Xcelium; ignorado pelo Git |

## Escopo

Esta e uma simulacao funcional *gate-level*. Ela demonstra que a netlist
sintetizada, usando os modelos das celulas padrao, preserva as funcoes
verificadas pelo testbench. Os atrasos de propagacao e os *timing checks* sao
avaliados separadamente na simulacao temporal com SDF.
