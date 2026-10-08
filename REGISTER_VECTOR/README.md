# Register Vector

Dois registradores vetoriais de 32 bits (`vector_a` e `vector_b`). Eles capturam os operandos retornados pela porta B da memória quando `load_a` ou `load_b` está ativo.

## Teste

```powershell
iverilog -g2012 -s register_vector_tb -o REGISTER_VECTOR\register_vector_tb.out REGISTER_VECTOR\register_vector.sv REGISTER_VECTOR\register_vector_tb.sv
vvp REGISTER_VECTOR\register_vector_tb.out
```
