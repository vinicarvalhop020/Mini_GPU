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

## Resultados:

### Artefatos e configuracao da sintese

| Item | Resultado |
| --- | --- |
| Top-level sintetizado | `gpu_simd` |
| Netlist mapeada | [`../SINTESE/netlist/gpu_simd.v`](../SINTESE/netlist/gpu_simd.v) |
| Ferramenta | Cadence Genus 22.16-s078_1 |
| Biblioteca e canto | GPDK045 `slow_vdd1v0_basicCells`, 0,9 V e 125 C |
| Restricao de clock | 20 ns (50 MHz), com 1 ns de incerteza |
| Implementacao da memoria | 256 x 64 bits em celulas padrao, pois nao foi usada uma macro SRAM dual-port |

Somente a RTL sintetizavel entra na sintese. Na simulacao gate-level, a RTL
nao e compilada: o DUT e a netlist mapeada, acompanhada pelos modelos Verilog
das celulas padrao da biblioteca.

**Fontes:** [script de sintese](../SINTESE/scripts/setup_gpu_simd.tcl),
[constraints SDC](../SINTESE/constraints/gpu_simd.sdc) e
[netlist gerada](../SINTESE/netlist/gpu_simd.v).

### Resultado de timing

| Medida | Resultado |
| --- | ---: |
| Periodo requerido | 20,000 ns |
| Tempo requerido apos setup e incerteza | 18,891 ns |
| Atraso do caminho critico | 16,055 ns |
| Slack de setup | **+2,836 ns** |
| TNS | 0,000 ns |
| Caminhos violadores | 0 |

O caminho critico parte de `u_vector_registers/vector_b_reg[48]`, atravessa
a logica de divisao da lane 3 da ALU SIMD e termina em
`u_vector_memory/mem_reg[254][63]`. Portanto, mesmo o caminho mais lento da
GPU atende a restricao de 50 MHz no canto lento analisado.

**Fontes:** [relatorio de timing](../SINTESE/reports/gpu_simd_timing.rpt) e
[resumo de qualidade da sintese](../SINTESE/reports/gpu_simd_qor.rpt).

### Area e potencia estimada

| Medida | Resultado |
| --- | ---: |
| Instancias de celula | 81.398 |
| Elementos sequenciais | 16.833 |
| Elementos combinacionais | 64.565 |
| Area total | 204.149,034 unidades da biblioteca |
| Area da memoria vetorial | 188.340,084 (92,26% da area total) |
| Potencia total estimada | 2,156 mW |

A memoria domina a area porque seus 16.384 bits foram implementados com
flip-flops e multiplexadores. Em um ASIC completo, uma macro SRAM dual-port
256 x 64 substituiria essa logica e reduziria significativamente a area.
A potencia e uma estimativa baseada no frame de atividade utilizado pelo
Genus; nao representa uma medicao fisica pos-layout.

**Fontes:** [relatorio de area](../SINTESE/reports/gpu_simd_area.rpt),
[relatorio de potencia](../SINTESE/reports/gpu_simd_power.rpt) e
[README da sintese](../SINTESE/README.md).

### Resultado da simulacao gate-level

| Modalidade | Configuracao | Resultado documentado |
| --- | --- | --- |
| Funcional | Netlist + modelos de celula, sem SDF, clock de 100 MHz | **PASSOU** em 1.526 ns |
| Temporal | Netlist + SDF `MAXIMUM`, clock de 50 MHz | **PASSOU** em 3.051 ns |

As duas modalidades compilam a mesma netlist
[`../SINTESE/netlist/gpu_simd.v`](../SINTESE/netlist/gpu_simd.v), o mesmo
testbench [`../GPU_SIMD/gpu_simd_tb.sv`](../GPU_SIMD/gpu_simd_tb.sv) e os
modelos Verilog da biblioteca lenta GPDK045. Assim, o DUT da simulacao e a
implementacao em celulas padrao, e nao a RTL original.

| Aspecto validado | Simulacao funcional | Simulacao temporal com SDF |
| --- | :---: | :---: |
| Escrita e leitura da memoria vetorial | PASSOU | PASSOU |
| ADD, SUB, MUL e DIV em quatro lanes SIMD | PASSOU | PASSOU |
| Divisao por zero e `rsp_error` | PASSOU | PASSOU |
| Sobrescrita de um endereco de destino | PASSOU | PASSOU |
| Multiplicacao assinada `-128 x -128` | PASSOU | PASSOU |
| Atrasos de celulas e timing checks | Nao se aplica | PASSOU |

Na simulacao temporal, o SDF foi gerado pelo Genus para o canto lento
`slow_vdd1v0_basicCells` (0,9 V e 125 C), anotado na instancia
`gpu_simd_tb.dut` com o modo `MAXIMUM` e executado com periodo de 20 ns.
Foram anotados 239.898 de 239.914 caminhos (99,99%), sem erros de anotacao
nem violacoes temporais registradas. O resultado e coerente com o slack
positivo de 2,836 ns encontrado na analise estatica.

Os scripts permitem reproduzir as duas execucoes em um ambiente que possua o
Genus, o Xcelium e a biblioteca GPDK045. Os logs do simulador sao artefatos
transitorios: os relatorios de sintese, os scripts de reproducao e este resumo
sao mantidos no repositorio como evidencia permanente.

**Fontes:** [script da simulacao funcional](funcionamento/run_netlist_sim.sh),
[documentacao funcional](funcionamento/README.md),
[script de geracao do SDF](timing/generate_sdf.tcl),
[script da simulacao temporal](timing/run_timing_sim.sh),
[anotacao SDF](timing/sdf_annotation.sv),
[documentacao temporal](timing/README.md) e
[relatorio temporal](timing/reports/gpu_simd_sdf_timing.rpt).

