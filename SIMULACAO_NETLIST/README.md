# Simulacao de Netlist da Mini GPU

Este diretorio guarda as duas verificacoes executadas sobre a netlist
sintetizada de `gpu_simd`. Em ambas, a RTL da GPU nao e compilada: o Xcelium
usa a netlist gerada pelo Genus e os modelos Verilog das celulas padrao.

| Modalidade | Atrasos SDF | Clock do testbench | Resultado |
| --- | --- | --- | --- |
| [Funcional](funcionamento/README.md) | Nao | 100 MHz | PASSOU em 1526 ns |
| [Temporal](timing/README.md) | Sim, `MAXIMUM` | 50 MHz | PASSOU em 3051 ns |

## O que as duas etapas cobrem

| Item verificado | Funcional | Temporal |
| --- | :---: | :---: |
| Leitura e escrita de memoria | Sim | Sim |
| Operacoes SIMD ADD, SUB, MUL e DIV | Sim | Sim |
| Divisao por zero e resposta de erro | Sim | Sim |
| Sobrescrita de destino | Sim | Sim |
| Multiplicacao assinada `-128 x -128` | Sim | Sim |
| Atrasos de celulas e *timing checks* | Nao | Sim |

## Como executar

No diretorio raiz da Mini GPU:

```bash
# Validacao funcional da netlist
./SIMULACAO_NETLIST/funcionamento/run_netlist_sim.sh

# Geracao do SDF e simulacao temporal
./SIMULACAO_NETLIST/timing/generate_sdf.sh
./SIMULACAO_NETLIST/timing/run_timing_sim.sh
```

A simulacao funcional mostra que o comportamento foi preservado apos a
sintese. A temporal acrescenta os atrasos MAXIMUM do canto lento da biblioteca
e confirma a execucao do mesmo conjunto de testes sem violacoes registradas.

