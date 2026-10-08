# ALU SIMD

Agrupa quatro instâncias de `alu_unit` para executar a mesma operação sobre quatro lanes de 8 bits. Os vetores de entrada e saída têm 32 bits.

## Teste

```powershell
iverilog -g2012 -s alu_simd_tb -o ALU_SIMD\alu_simd_tb.out ALU_UNIT\alu_unit.sv ALU_SIMD\alu_simd.sv ALU_SIMD\alu_simd_tb.sv
vvp ALU_SIMD\alu_simd_tb.out
```
