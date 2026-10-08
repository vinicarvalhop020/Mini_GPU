# AXI Slave simplificado

Interpreta os pacotes do `packet_decoder` e controla a porta A da memória, o Scheduler e a resposta ao host.

Tipos de pacote:

- `00`: leitura da memória vetorial;
- `01`: escrita da memória vetorial;
- `10`: armazenamento de `GPU_COMMAND`;
- `11`: início da execução com `GPU_START`.

## Teste

```powershell
iverilog -g2012 -s axi_slave_tb -o AXI_SLAVE\axi_slave_tb.out AXI_SLAVE\axi_slave.sv AXI_SLAVE\axi_salve_tb.sv
vvp AXI_SLAVE\axi_slave_tb.out
```
