// ============================================================================
// Control Unit Module
// Generates control signals based on operation type
// ============================================================================

module control_unit (
    input [1:0] op_type,          // 00: NOP, 01: ALU, 10: LOAD, 11: STORE
    
    output reg alu_src,           // 0: register, 1: immediate
    output reg mem_read,          // Read from memory
    output reg mem_write,         // Write to memory
    output reg reg_write,         // Write to register
    output reg mem_to_reg         // Select MEM data for write back
);

    always @(*) begin
        case (op_type)
            2'b00: begin  // NOP
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                reg_write = 0;
                mem_to_reg = 0;
            end
            2'b01: begin  // ALU
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                reg_write = 1;
                mem_to_reg = 0;
            end
            2'b10: begin  // LOAD
                alu_src = 1;
                mem_read = 1;
                mem_write = 0;
                reg_write = 1;
                mem_to_reg = 1;
            end
            2'b11: begin  // STORE
                alu_src = 1;
                mem_read = 0;
                mem_write = 1;
                reg_write = 0;
                mem_to_reg = 0;
            end
            default: begin
                alu_src = 0;
                mem_read = 0;
                mem_write = 0;
                reg_write = 0;
                mem_to_reg = 0;
            end
        endcase
    end

endmodule