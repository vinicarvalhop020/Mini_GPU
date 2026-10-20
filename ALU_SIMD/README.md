# ALU SIMD

Agrupa quatro instâncias de `alu_unit` para executar a mesma operação sobre quatro
lanes signed de 16 bits. Os vetores de entrada e saída têm 64 bits, e a saída
`error` é ativada se qualquer lane tiver overflow ou divisão por zero.

## Teste

```powershell
iverilog -g2012 -s alu_simd_tb -o ALU_SIMD\alu_simd_tb.out ALU_UNIT\alu_unit.sv ALU_SIMD\alu_simd.sv ALU_SIMD\alu_simd_tb.sv
vvp ALU_SIMD\alu_simd_tb.out
```
