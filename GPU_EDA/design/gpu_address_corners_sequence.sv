`include "uvm_macros.svh"
import uvm_pkg::*;

// Enderecos 0x00/0xFF e alias entre fonte e destino.
class gpu_address_corners_sequence extends gpu_base_sequence;
    `uvm_object_utils(gpu_address_corners_sequence)

    function new(string name = "gpu_address_corners_sequence");
        super.new(name);
    endfunction

    virtual task body();
        logic [63:0] read_data;

        // Escrita nos endereços de borda
        write_vector(8'h00, 32'h01_02_03_04);
        write_vector(8'hFF, 32'h10_20_30_40);

        // src_a == src_b e destino igual a uma das fontes.
        // Operação é sequencial entao nao deve haver sobreposição de 
        //leituras/escritas, que causariam conflitos.
        execute_operation(8'h01, 8'h00, 8'h00, 8'h00);
        read_vector(8'h00, read_data);

        // Operação de multiplicação com valores de borda e salvamento do resultado na borda.
        execute_operation(8'h03, 8'h00, 8'hFF, 8'hFF);
        read_vector(8'hFF, read_data);
    endtask
endclass
