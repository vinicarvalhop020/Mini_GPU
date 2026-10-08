## Simulacao

Foram criados dois testbenchs para testar a GPU SIMD: um para os comandos individuais e outro para a multiplicacao de matrizes 4x4.
Os comandos abaixo foram preparados para PowerShell com Icarus Verilog, inicialmente.

Primeiro, declare a lista comum de modulos RTL:

```powershell
$rtl = @(
  'ALU_UNIT\alu_unit.sv',
  'ALU_SIMD\alu_simd.sv',
  'DUALPORT_MEMORY\dualport_memory.sv',
  'REGISTER_VECTOR\register_vector.sv',
  'SCHEDULER\scheduler.sv',
  'FSM\fsm.sv',
  'PACKET_DECODER\packet_decoder.sv',
  'AXI_SLAVE\axi_slave.sv',
  'GPU_SIMD\gpu_simd.sv'
)
```

### Teste funcional da GPU

Valida os comandos `ADD`, `SUB`, `MUL` e `DIV`, incluindo divisao por zero, o status `DONE` e a sobrescrita de um vetor destino.

```powershell
iverilog -g2012 -s gpu_simd_tb -o GPU_SIMD\gpu_simd_tb.out $rtl 'GPU_SIMD\gpu_simd_tb.sv'

vvp GPU_SIMD\gpu_simd_tb.out
```

O teste deve terminar com:

```text
[TB] PASSOU: todos os comandos SIMD foram validados.
```

### Teste de multiplicacao de matrizes 4x4

Executa uma multiplicacao matricial como programa de host: grava os vetores na memoria, envia os comandos SIMD em sequencia e confere a matriz resultante.

```powershell
iverilog -g2012 -s gpu_simd_matrix_mul_tb -o GPU_SIMD\gpu_simd_matrix_mul_tb.out $rtl 'GPU_SIMD\gpu_simd_matrix_mul_tb.sv'

vvp GPU_SIMD\gpu_simd_matrix_mul_tb.out
```

O teste deve terminar com:

```text
[TB] PASSOU: multiplicacao de matrizes 4x4 concluida.
```
# GPU SIMD

Top-level que conecta Packet Decoder, AXI Slave, Scheduler, FSM, memória dual-port, registradores vetoriais e ALU SIMD.

Os comandos para executar os testes de comandos SIMD e de multiplicação matricial estão no [README da raiz](../README.md).
