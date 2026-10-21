# Gera SDF a partir da netlist ja mapeada, sem sintetizar a RTL novamente.

set TIMING_DIR [file normalize [file dirname [info script]]]
set SIM_DIR [file normalize [file join $TIMING_DIR ..]]
set PROJECT_DIR [file normalize [file join $SIM_DIR ..]]
set LIB_DIR "/pdk/gpdk045/gsclib045_svt_v4.7/gsclib045/timing"
set TOP "gpu_simd"

set_db lib_search_path $LIB_DIR
set_db library {slow_vdd1v0_basicCells.lib}

read_hdl -sv "$PROJECT_DIR/SINTESE/netlist/gpu_simd.v"
elaborate $TOP
set_top_module $TOP

# Usa clock de 20 ns, incerteza e atrasos de E/S exportados pela sintese.
read_sdc "$PROJECT_DIR/SINTESE/netlist/gpu_simd.sdc"

report_timing -max_paths 1 > "$TIMING_DIR/reports/gpu_simd_sdf_timing.rpt"
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge \
    -setuphold split > "$TIMING_DIR/gpu_simd.sdf"

exit
