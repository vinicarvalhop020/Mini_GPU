# Sintese da Mini GPU

Esta pasta sintetiza o top-level `gpu_simd` com o Cadence Genus. Somente a RTL
da GPU entra no fluxo; UVM, assertions e testbenches ficam fora.

## Como executar

No diretorio raiz da Mini GPU:

```bash
./SINTESE/run_synthesis.sh
```

O fluxo usa a biblioteca lenta `slow_vdd1v0_basicCells.lib` (0,9 V e 125 °C)
e um clock de 20 ns, equivalente a 50 MHz.

## Abrir a netlist na GUI

Depois da sintese, execute:

```bash
./SINTESE/open_gui.sh
```

Na janela do Genus, expanda `gpu_simd` no *Design Browser*. Para um screenshot
legivel, abra o esquematico de um bloco menor, como `u_alu_simd`, uma instancia
`gen_alu_lanes[0].alu_lane` ou `u_axi_slave`. O esquematico do topo completo
tem mais de 81 mil celulas e ficara muito poluido.

## Exportar um esquematico em imagem

Para gerar automaticamente o esquematico sintetizado do SIMD:

```bash
./SINTESE/export_schematic.sh
```

O arquivo criado sera `schematics/alu_simd_schematic.gif`.

## Resultados

- `netlist/gpu_simd.v`: netlist Verilog mapeada em celulas padrao.
- `netlist/gpu_simd.sdc`: constraints exportadas pelo Genus.
- `reports/gpu_simd_area.rpt`: area total e area por modulo.
- `reports/gpu_simd_timing.rpt`: caminho critico e slack.
- `reports/gpu_simd_power.rpt`: estimativa de potencia.
- `reports/gpu_simd_qor.rpt`: resumo de qualidade da implementacao.
- `logs/genus.log`: log da execucao.

`work/` contem somente arquivos temporarios do Genus e pode ser removido antes
de uma nova execucao. A memoria vetorial e descrita como RTL; sem uma macro SRAM,
o Genus a implementa com celulas logicas, o que aumenta a area estimada.


## Resultados vistos:

Na primeira execução o genus está expandiu cada acesso da dualport_memory em multiplexadores, e ainda avalia muitas configurações internas.
Isso resultou em uma area de:
