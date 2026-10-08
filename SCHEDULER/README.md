# Scheduler

Armazena um comando GPU de 32 bits e faz a ponte entre o AXI Slave e a FSM de execução.

Estados: `IDLE`, `DISPATCH`, `EXECUTE` e `DONE`. O bit `done` permanece ativo até que um novo comando seja aceito.

## Teste

```powershell
iverilog -g2012 -s scheduler_tb -o SCHEDULER\scheduler_tb.out SCHEDULER\scheduler.sv SCHEDULER\scheduler_tb.sv
vvp SCHEDULER\scheduler_tb.out
```
