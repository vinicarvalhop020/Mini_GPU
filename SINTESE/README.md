# Sintese da Mini GPU

Esta pasta sintetiza o top-level `gpu_simd` com o Cadence Genus. Somente a RTL
da GPU entra no fluxo.

## Como executar

No diretorio raiz da Mini GPU:

```bash
./SINTESE/run_synthesis.sh
```

O fluxo usa a biblioteca lenta `slow_vdd1v0_basicCells.lib` (0,9 V e 125 °C)
e um clock de 20 ns, equivalente a 50 MHz. Vista em laboratório.

## Abrir a netlist na GUI

Depois da sintese, execute:

## Exportar um esquematico em imagem

Para gerar automaticamente o esquematico sintetizado do SIMD:
Uma imagem do esquematico, atualmente existe em `schematics/alu_simd_schematic.gif`.

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


## Resultados vistos

A `dualport_memory` possui 256 palavras de 64 bits, totalizando
16.384 bits de armazenamento.

Como a biblioteca GPDK045 disponível no laboratório não contém uma
macro SRAM de duas portas compatível, o Genus inferiu a memória usando
células padrão: flip-flops para armazenamento e multiplexadores para
seleção dos endereços.

Como consequência, a memória ocupou uma área de `188340.084`,
equivalente a `92,26%` da área total da Mini GPU (`204149.034`).

Em uma implementação ASIC real, essa memória seria substituída por uma
macro SRAM 256x64 de duas portas. Nesse caso, o Genus utilizaria a área
e os atrasos fornecidos pela biblioteca da macro, reduzindo
significativamente a área e o tempo de síntese.