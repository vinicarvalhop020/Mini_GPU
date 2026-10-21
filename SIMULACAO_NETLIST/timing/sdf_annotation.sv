// Anota na instancia da netlist os atrasos extraidos pelo Genus.
module sdf_annotation;
    initial begin
        $sdf_annotate("../gpu_simd.sdf", $root.gpu_simd_tb.dut, , , "MAXIMUM");
        $display("[SDF] Atrasos MAXIMUM anotados em gpu_simd_tb.dut.");
    end
endmodule
