# Clock de 50 MHz (periodo de 20 ns), como no roteiro RISCV.
create_clock -name clock -period 20 [get_ports clk]
set_clock_uncertainty 1 [get_clocks clock]

# As entradas de dados chegam ate 1 ns apos a borda do clock.
# clk e rst ficam de fora: sao sinais de infraestrutura, nao dados.
set_input_delay 1 -clock clock \
    [remove_from_collection [all_inputs] [get_ports {clk rst}]]
set_output_delay 1 -clock clock [all_outputs]

# Clock e reset nao recebem atraso de logica externa nesta sintese.
set_ideal_net [get_nets clk]
set_ideal_net [get_nets rst]
