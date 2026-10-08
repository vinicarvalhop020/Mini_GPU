# Dual Port Memory

Memória vetorial de 256 palavras de 32 bits. Possui duas portas síncronas independentes:

- Porta A: acesso do host pelo AXI Slave.
- Porta B: acesso da FSM durante a execução da GPU.

As leituras são síncronas e, quando A e B escrevem no mesmo endereço, a escrita da porta B prevalece.

## Teste

```powershell
iverilog -g2012 -s dualport_memory_tb -o DUALPORT_MEMORY\dualport_memory_tb.out DUALPORT_MEMORY\dualport_memory.sv DUALPORT_MEMORY\dualport_memory_tb.sv
vvp DUALPORT_MEMORY\dualport_memory_tb.out
```
