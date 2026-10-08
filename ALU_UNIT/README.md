# ALU Unit

ALU escalar de 8 bits usada por cada lane da GPU SIMD.

Operações: `ADD = 1`, `SUB = 2`, `MUL = 3` e `DIV = 4`. Divisão por zero retorna `0`.

## Teste

```powershell
iverilog -g2012 -s alu_unit_tb -o ALU_UNIT\alu_unit_tb.out ALU_UNIT\alu_unit.sv ALU_UNIT\alu_unit_tb.sv
vvp ALU_UNIT\alu_unit_tb.out
```
