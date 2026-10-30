# Simulacao Temporal da Netlist

Esta etapa complementa a simulacao funcional. O Genus extrai os atrasos da
netlist para um arquivo SDF e o Xcelium os anota na instancia
`gpu_simd_tb.dut`. Assim, o mesmo testbench executa usando os atrasos da
implementacao mapeada em celulas.

## Ambiente da simulacao

| Item | Configuracao |
| --- | --- |
| Simulador | Xcelium |
| Ferramenta de extracao do SDF | Genus |
| Projeto verificado | `gpu_simd` |
| Implementacao | `SINTESE/netlist/gpu_simd.v` |
| Biblioteca de timing | canto lento, 0,9 V e 125 °C |
| SDF | Valores `MAXIMUM`, em nanossegundos |
| Testbench | `GPU_SIMD/gpu_simd_tb.sv` |
| Clock do testbench | 50 MHz (periodo de 20 ns), igual a constraint de sintese |

## Executar

No diretorio raiz da Mini GPU:

```bash
./SIMULACAO_NETLIST/timing/generate_sdf.sh
./SIMULACAO_NETLIST/timing/run_timing_sim.sh
```

O primeiro comando gera o SDF a partir da netlist; o segundo anota esse SDF e
executa a simulacao temporal.

## O que foi testado

| Caso | Verificacao feita |
| --- | --- |
| Acesso a memoria | Escrita e leitura de operandos e resultados nas memorias da GPU |
| ADD | Soma SIMD apos a anotacao dos atrasos MAXIMUM |
| SUB | Subtracao SIMD apos a anotacao dos atrasos MAXIMUM |
| MUL | Multiplicacao SIMD e armazenamento do resultado |
| DIV com divisor zero | Resultado e sinalizacao de erro esperados pelo protocolo |
| Sobrescrita de destino | Atualizacao correta de um endereco ja utilizado |
| Operacao assinada | Multiplicacao `-128 x -128`, validando o caminho de dados `int8` |

## Resultado obtido

| Medida | Resultado |
| --- | --- |
| Status funcional com SDF | **PASSOU** |
| Tempo final da simulacao | 3051 ns |
| Atrasos de caminho anotados | 239898 de 239914 (99,99%) |
| Erros na anotacao SDF | 0 |
| Violacoes temporais registradas | 0 |
| Mensagem final | `[TB] PASSOU: todos os comandos SIMD foram validados.` |

Como referencia de analise estatica, o relatorio de sintese para a mesma
constraint de 50 MHz obteve *slack* de aproximadamente 2,836 ns. Portanto, o
caminho critico atende ao periodo de 20 ns e o teste temporal tambem concluiu
sem violacoes registradas.

### Avisos de anotacao

O Xcelium emitiu 321 avisos de `REMOVAL`, pois alguns desses *timing checks*
nao estao declarados no modelo Verilog das celulas da biblioteca. Eles nao
impediram a anotacao dos atrasos de caminho nem dos checks relevantes de
setup/hold. A simulacao terminou sem erros de anotacao e sem violacoes de
timing registradas.

## Artefatos

| Arquivo ou diretorio | Conteudo |
| --- | --- |
| `generate_sdf.sh` | Chama o Genus para gerar o SDF |
| `run_timing_sim.sh` | Compila a netlist, anota o SDF e executa o Xcelium |
| `gpu_simd.sdf` | Atrasos extraidos da netlist; gerado localmente e ignorado pelo Git |
| `reports/gpu_simd_sdf_timing.rpt` | Relatorio de timing usado na geracao do SDF |
| `work/` | Diretorio temporario de compilacao; ignorado pelo Git |

## Relacao com a simulacao funcional

A simulacao em [`../funcionamento`](../funcionamento/README.md) usa a mesma
netlist, mas sem atrasos SDF. Ela isola a validacao funcional. Esta etapa
acrescenta os atrasos MAXIMUM e os *timing checks*.
