# Packet Decoder

Recebe um pacote de 42 bits do host, armazena-o e o expõe ao AXI Slave usando handshake `valid/ready`.

Formato: `{TYPE[1:0], FIELD_0, FIELD_1, FIELD_2, FIELD_3, FIELD_4}`, com cinco campos de 8 bits.

## Teste

```powershell
iverilog -g2012 -s packet_decoder_tb -o PACKET_DECODER\packet_decoder_tb.out PACKET_DECODER\packet_decoder.sv PACKET_DECODER\packet_decoder_tb.sv
vvp PACKET_DECODER\packet_decoder_tb.out
```
