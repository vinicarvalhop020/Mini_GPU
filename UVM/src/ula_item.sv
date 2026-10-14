
class ula_item extends uvm_sequence_item;
    `uvm_object_utils(ula_item)
    
    rand logic [31:0] a;
    rand logic [31:0] b;
    rand logic [2:0] opr;
    logic [63:0] result;
    logic carry_o;
    logic zero;
    logic rst_n;

    // Operações (mesmos códigos usados no RTL)
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_MUL = 3'b010;
    localparam OP_DIV = 3'b011;
    localparam OP_AND = 3'b100;
    localparam OP_OR  = 3'b101;
    localparam OP_NOT = 3'b110;

    constraint opr_val {
        opr inside {
        OP_ADD, OP_SUB, OP_MUL, OP_DIV,
        OP_AND, OP_OR, OP_NOT
        };
    }

    constraint reasonable_values {
        a dist {
            32'h0000_0000                 := 5,
            32'h0000_0001                 := 5,
            [32'h0000_0002:32'h0000_FFFF] :/ 25,
            [32'h0001_0000:32'h5555_5554] :/ 25,
            [32'h5555_5556:32'h7FFF_FFFF] :/ 25,
            32'h5555_5555                 := 5,
            [32'h8000_0000:32'hAAAA_AAA9] :/ 25,
            [32'hAAAA_AAAB:32'hFFFF_FFFE] :/ 25,
            32'hAAAA_AAAA                 := 5,
            32'hFFFF_FFFF                 := 5
        };

        b dist {
            32'h0000_0000                 := 5,
            32'h0000_0001                 := 5,
            [32'h0000_0002:32'h0000_FFFF] :/ 25,
            [32'h0001_0000:32'h5555_5554] :/ 25,
            [32'h5555_5556:32'h7FFF_FFFF] :/ 25,
            32'h5555_5555                 := 5,
            [32'h8000_0000:32'hAAAA_AAA9] :/ 25,
            [32'hAAAA_AAAB:32'hFFFF_FFFE] :/ 25,
            32'hAAAA_AAAA                 := 5,
            32'hFFFF_FFFF                 := 5
        };
    }

    function new(string name = "ula_item");
        super.new(name);
    endfunction
    
    function string convert2string();
        return $sformatf( "%s: a=0x%8h, b=0x%8h -> result=0x%8h, carry_o=%0d", get_type_name(), 
                         a, b, result, carry_o);
    endfunction
    
endclass

class facil_transaction extends ula_item;
    `uvm_object_utils(facil_transaction)

    constraint reasonable_values {
        a inside {[0:32'd100]};
	b inside {[0:32'd100]};
    }

    function new(string name = "facil_transaction");
        super.new(name);
    endfunction

endclass

class limite_transaction extends ula_item;
    `uvm_object_utils(limite_transaction)

    constraint reasonable_values {
        a > {32'hFFFFFF00};
	b > {32'hFFFFFF00};
    }

    function new(string name = "limite_transaction");
        super.new(name);
    endfunction

endclass
