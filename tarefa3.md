Plano passo a passo
1. Mapear a interface verificável (OK)
Antes de criar classes, definiremos a fronteira do DUT:
clk, rst
req_payload[41:0]
req_valid
req_ready
rsp_data[31:0]
rsp_valid
rsp_error
Decisão: o UVM verificará a GPU pela interface do host, igual um software/CPU a enxergaria. Não começaremos acessando sinais internos.
Resultado: documento curto com o formato do pacote e os handshakes que o driver e monitor devem respeitar.
2. Criar gpu_host_if
Arquivo: UVM/gpu/src/gpu_host_if.sv.
Ele conterá:
- os sinais da interface do host;
- clocking block para eliminar corridas entre driver, monitor e DUT;
- modport DUT;
- modport TB.
Também será o local natural para as assertions de protocolo externo.
Resultado: top-level pode conectar a GPU à interface, e as classes UVM podem usar uma virtual gpu_host_if.
3. Criar o item de transação
Arquivo: gpu_item.sv.
Ele representará um pacote de host:
tipo de pacote
field_0 ... field_4
rsp_data
rsp_error
Os quatro tipos serão enumerados:
MEM_READ
MEM_WRITE
GPU_COMMAND
GPU_START
Ainda não haverá randomização avançada nem coverage. A transação será criada de forma direcionada.
Resultado: deixamos de pensar em pinos e passamos a pensar em “enviar um comando para a GPU”.
4. Criar sequencer, sequence e driver
Arquivos:
gpu_sequencer.sv
gpu_sequence.sv
gpu_driver.sv
O driver fará o protocolo real:
1. coloca o pacote em req_payload;
2. ativa req_valid;
3. espera req_ready;
4. desativa req_valid;
5. espera rsp_valid;
6. salva rsp_data e rsp_error.
A primeira sequence terá apenas uma operação simples, como um MEM_WRITE.
Resultado: primeira transação UVM chega à GPU e recebe resposta.
5. Criar monitor
Arquivo: gpu_monitor.sv.
O monitor não dirige nada. Ele observará:
- aceitação de pacote: req_valid && req_ready;
- resposta do DUT: rsp_valid.
Como a GPU aceita uma requisição por vez, o monitor poderá associar facilmente a resposta ao pacote aceito e publicar uma transação observada em uma uvm_analysis_port.
Resultado: o ambiente tem observabilidade independente do driver.
6. Criar agent, env, config e test
Arquivos:
gpu_agent_config.sv
gpu_env_config.sv
gpu_agent.sv
gpu_env.sv
gpu_base_test.sv
Relação:
gpu_base_test
└── gpu_env
    └── gpu_agent
        ├── gpu_sequencer
        ├── gpu_driver
        └── gpu_monitor
O test criará o ambiente, obterá a interface via uvm_config_db, iniciará a sequence mínima e controlará a objection.
Resultado: arquitetura UVM completa, mesmo sem scoreboard e coverage.
7. Criar o top-level UVM
Arquivo: UVM/gpu/tb/gpu_top_tb.sv.
Responsabilidades:
- gerar clock e reset;
- instanciar gpu_host_if;
- instanciar gpu_simd;
- colocar a virtual interface no uvm_config_db;
- chamar run_test().
Resultado: código pronto para EDA Playground.
8. Criar Assertions de protocolo
Arquivo inicial: UVM/gpu/assertions/gpu_host_protocol_sva.sv.
Assertions externas da interface:
- se req_valid=1 e req_ready=0, o pacote deve permanecer estável;
- req_valid deve continuar ativo até o handshake;
- rsp_valid deve ser um pulso de um ciclo;
- rsp_error permanece zero enquanto erros não forem implementados.
Essas properties ficam na interface ou em um checker conectado a ela.
9. Criar Assertions internas via bind
Arquivos:
scheduler_sva.sv
fsm_sva.sv
gpu_bind.sv
Sem alterar o RTL, o bind conectará checkers aos módulos.
Properties iniciais:
- done do Scheduler persiste até novo comando;
- exec_done ocorre apenas em FINISH;
- FINISH retorna para IDLE;
- mem_b_we só ocorre em WRITE_RESULT;
- load_a e load_b não são ativados simultaneamente;
- leitura e escrita da porta B não ocorrem simultaneamente.
Resultado: verificação temporal de sinais internos sem misturar código de verificação com RTL.
10. Organizar compilação e documentação
Arquivos:
UVM/gpu/files.f
UVM/gpu/README.md
O files.f definirá a ordem de compilação. O README terá o passo a passo para reproduzir no EDA Playground.
Ordem de implementação
A sequência ideal para aprendermos é:
1. interface;
2. transaction;
3. driver;
4. sequência mínima;
5. top-level e EDA Playground;
6. monitor;
7. agent/env/test/config;
8. assertions da interface;
9. assertions com bind.
Quando iniciarmos, começamos pelo passo 1: desenhar e criar gpu_host_if.sv.