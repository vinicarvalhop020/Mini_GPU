# FSM de execução

Controla a execução de um comando SIMD na porta B da memória.

Sequência: `IDLE → READ_A → LOAD_A → READ_B → LOAD_B → EXECUTE → WRITE_RESULT → FINISH`.

O comando tem o formato `{opcode, src_a, src_b, dst}`. Em `FINISH`, a FSM gera `exec_done` por um ciclo.

## Teste

```powershell
iverilog -g2012 -s fsm_tb -o FSM\fsm_tb.out FSM\fsm.sv FSM\fsm_tb.sv
vvp FSM\fsm_tb.out
```
