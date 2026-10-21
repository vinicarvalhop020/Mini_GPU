# Fluxo de sintese simples da Mini GPU usando Cadence Genus.

# Diretorios do projeto.
set SYN_DIR [file normalize [file join [file dirname [info script]] ..]]
set PROJECT_DIR [file normalize [file join $SYN_DIR ..]]
set LIB_DIR "/pdk/gpdk045/gsclib045_svt_v4.7/gsclib045/timing"

# Top-level e arquivos RTL sintetizaveis. Testbenches e UVM nao entram aqui.
set HDL_NAME "gpu_simd"
set HDL_FILES [list \
    "$PROJECT_DIR/ALU_UNIT/alu_unit.sv" \
    "$PROJECT_DIR/ALU_SIMD/alu_simd.sv" \
    "$PROJECT_DIR/AXI_SLAVE/axi_slave.sv" \
    "$PROJECT_DIR/DUALPORT_MEMORY/dualport_memory.sv" \
    "$PROJECT_DIR/REGISTER_VECTOR/register_vector.sv" \
    "$PROJECT_DIR/SCHEDULER/scheduler.sv" \
    "$PROJECT_DIR/FSM/fsm.sv" \
    "$PROJECT_DIR/PACKET_DECODER/packet_decoder.sv" \
    "$PROJECT_DIR/GPU_SIMD/gpu_simd.sv"]

# Canto pessimista: 0,9 V e 125 graus C.
set WORST_LIST {slow_vdd1v0_basicCells.lib}

# Mantem os blocos da GPU visiveis no relatorio de area.
set_db auto_ungroup none

# Biblioteca de celulas e leitura da RTL.
set_db hdl_search_path $PROJECT_DIR
set_db lib_search_path $LIB_DIR
set_db library $WORST_LIST

read_hdl -sv $HDL_FILES
elaborate $HDL_NAME
set_top_module $HDL_NAME
check_design -unresolved

# Restricoes temporais.
read_sdc "$SYN_DIR/constraints/gpu_simd.sdc"

# Sintese: RTL -> logica generica -> celulas da biblioteca.
syn_generic $HDL_NAME
syn_map $HDL_NAME

# Relatorios e artefatos finais.
report_timing > "$SYN_DIR/reports/${HDL_NAME}_timing.rpt"
report_area   > "$SYN_DIR/reports/${HDL_NAME}_area.rpt"
report_power  > "$SYN_DIR/reports/${HDL_NAME}_power.rpt"
report_qor    > "$SYN_DIR/reports/${HDL_NAME}_qor.rpt"

write_hdl $HDL_NAME > "$SYN_DIR/netlist/${HDL_NAME}.v"
write_sdc > "$SYN_DIR/netlist/${HDL_NAME}.sdc"

exit
