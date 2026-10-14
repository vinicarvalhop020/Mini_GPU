# Assertions da GPU SIMD

Os checkers ficam fora do RTL. Assim, a GPU continua sintetizavel e as
assertions podem ser habilitadas somente durante a simulacao.

| Arquivo | Onde verifica | Regras iniciais |
| --- | --- | --- |
| `gpu_host_protocol_sva.sv` | Interface host da GPU | Estabilidade durante `valid/ready`, pulso de resposta e ausencia de erro. |
| `scheduler_sva.sv` | Modulo `scheduler` | Persistencia de `done`, reinicio por novo comando e coerencia de `busy`. |
| `fsm_sva.sv` | Modulo `fsm` | Relacao FINISH/`exec_done`, acesso a memoria e exclusividade dos loads. |
| `gpu_bind.sv` | Compilacao | Liga Scheduler e FSM aos seus checkers via `bind`. |

Defina a macro `ASSERTIONS` para compilar essas verificacoes. O checker de
protocolo e instanciado no `gpu_top_tb`; os checkers internos usam `bind`,
portanto nao exigem mudar as portas do RTL.
