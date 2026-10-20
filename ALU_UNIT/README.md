# ALU Unit

ALU escalar signed de 16 bits usada por cada lane da GPU SIMD. Os operandos
do host são `int8` e entram na memória com extensão de sinal.

Operações: `ADD = 1`, `SUB = 2`, `MUL = 3` e `DIV = 4`. A saída `error` é
ativada em overflow signed ou divisão por zero; neste último caso o resultado é `0`.

## Teste

```powershell
iverilog -g2012 -s alu_unit_tb -o ALU_UNIT\alu_unit_tb.out ALU_UNIT\alu_unit.sv ALU_UNIT\alu_unit_tb.sv
vvp ALU_UNIT\alu_unit_tb.out
```
