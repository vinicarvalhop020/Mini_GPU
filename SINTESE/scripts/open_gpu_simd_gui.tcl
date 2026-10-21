# Carrega a netlist ja sintetizada e abre a GUI do Genus.
# Nao executa syn_generic nem syn_map novamente.

set SYN_DIR [file normalize [file join [file dirname [info script]] ..]]
set LIB_DIR "/pdk/gpdk045/gsclib045_svt_v4.7/gsclib045/timing"
set HDL_NAME "gpu_simd"

set_db lib_search_path $LIB_DIR
set_db library {slow_vdd1v0_basicCells.lib}

read_hdl -sv "$SYN_DIR/netlist/${HDL_NAME}.v"
elaborate $HDL_NAME
set_top_module $HDL_NAME
read_sdc "$SYN_DIR/netlist/${HDL_NAME}.sdc"

gui_show
