# Exporta em GIF o esquematico sintetizado do bloco SIMD.
# A netlist e carregada; nenhuma sintese e executada aqui.

set SYN_DIR [file normalize [file join [file dirname [info script]] ..]]
set LIB_DIR "/pdk/gpdk045/gsclib045_svt_v4.7/gsclib045/timing"
set HDL_NAME "gpu_simd"
set IMAGE_FILE "$SYN_DIR/schematics/alu_simd_schematic.gif"

set_db lib_search_path $LIB_DIR
set_db library {slow_vdd1v0_basicCells.lib}

read_hdl -sv "$SYN_DIR/netlist/${HDL_NAME}.v"
elaborate $HDL_NAME
set_top_module $HDL_NAME

gui_show
after 1000
gui_update
# gui_sv_load cria o visualizador principal, que e o alvo de gui_snapshot_sv.
gui_sv_load u_alu_simd
after 1000
gui_update
gui_snapshot_sv -overwrite $IMAGE_FILE

exit
