# Une todos os bancos individuais de COVERAGE/scope em scope/merged.

set scope_dir "COVERAGE/scope"
set runs {}

foreach path [glob -nocomplain -directory $scope_dir *] {
    if {[file isdirectory $path] && [file tail $path] ne "merged"} {
        lappend runs $path
    }
}

if {[llength $runs] == 0} {
    error "Nenhum banco individual foi encontrado em $scope_dir"
}

eval merge $runs -out "$scope_dir/merged" -overwrite
