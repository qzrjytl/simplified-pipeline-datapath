// ============================================================================
// Simplified Five-Stage Pipeline Datapath
// Main Module
// ============================================================================

module pipeline_datapath (
    input clk,
    input reset,
    
    // Instruction input
    input valid,
    input [1:0] op_type,      // 00: NOP, 01: ALU, 10: LOAD, 11: STORE
    input [2:0] rs1, rs2, rd,  // Register addresses
    input [15:0] imm,          // Immediate value
    input [2:0] alu_op,        // ALU operation
    input [1:0] byte_en,       // Byte enable
    
    // Output monitoring
    output reg [15:0] r1, r2, r3, r4, r5, r7,
    output reg [15:0] mem_out
);

    // Register file
    reg [15:0] regs [0:7];
    
    // Pipeline registers
    reg [1:0] if_id_op_type;
    reg [2:0] if_id_rs1, if_id_rs2, if_id_rd;
    reg [15:0] if_id_imm, if_id_rs1_data, if_id_rs2_data;
    reg if_id_valid;
    
    reg [1:0] id_ex_op_type;
    reg [2:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    reg [2:0] id_ex_alu_op;
    reg [15:0] id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    reg [1:0] id_ex_byte_en;
    reg id_ex_valid;
    
    reg [1:0] ex_mem_op_type;
    reg [2:0] ex_mem_rd;
    reg [15:0] ex_mem_alu_result;
    reg [15:0] ex_mem_store_data;
    reg [15:0] ex_mem_mem_addr;
    reg [1:0] ex_mem_byte_en;
    reg ex_mem_valid;
    
    reg [1:0] mem_wb_op_type;
    reg [2:0] mem_wb_rd;
    reg [15:0] mem_wb_result;
    reg mem_wb_valid;
    
    // Memory
    reg [15:0] memory [0:255];
    
    // Wire declarations
    wire [15:0] alu_result;
    wire [15:0] forwarded_rs1_data, forwarded_rs2_data;
    
    // ========================================================================
    // ALU Module
    // ========================================================================
    alu u_alu (
        .operand1(id_ex_rs1_data),
        .operand2(id_ex_rs2_data),
        .alu_op(id_ex_alu_op),
        .result(alu_result)
    );
    
    // ========================================================================
    // Data Forwarding Logic
    // ========================================================================
    assign forwarded_rs1_data = (if_id_rs1 == ex_mem_rd && ex_mem_valid && if_id_rs1 != 0) ?
                                ex_mem_alu_result :
                                (if_id_rs1 == mem_wb_rd && mem_wb_valid && if_id_rs1 != 0) ?
                                mem_wb_result :
                                if_id_rs1_data;
    
    assign forwarded_rs2_data = (if_id_rs2 == ex_mem_rd && ex_mem_valid && if_id_rs2 != 0) ?
                                ex_mem_alu_result :
                                (if_id_rs2 == mem_wb_rd && mem_wb_valid && if_id_rs2 != 0) ?
                                mem_wb_result :
                                if_id_rs2_data;
    
    // ========================================================================
    // Sequential Logic
    // ========================================================================
    
    always @(posedge clk) begin
        if (reset) begin
            // Initialize registers
            regs[1] <= 16'h0004;
            regs[2] <= 16'h0006;
            regs[3] <= 16'h1234;
            regs[7] <= 16'h00FF;
            regs[0] <= 16'h0000;
            regs[4] <= 16'h0000;
            regs[5] <= 16'h0000;
            regs[6] <= 16'h0000;
            
            // Initialize memory
            memory[0] <= 16'h0000;
            memory[1] <= 16'h0001;
            // ... initialize rest of memory as needed
            
            // Reset pipeline registers
            if_id_valid <= 0;
            id_ex_valid <= 0;
            ex_mem_valid <= 0;
            mem_wb_valid <= 0;
        end
        else begin
            // ====== IF/ID Stage ======
            if (valid) begin
                if_id_op_type <= op_type;
                if_id_rs1 <= rs1;
                if_id_rs2 <= rs2;
                if_id_rd <= rd;
                if_id_imm <= imm;
                if_id_rs1_data <= regs[rs1];
                if_id_rs2_data <= regs[rs2];
                if_id_valid <= valid;
            end else begin
                if_id_valid <= 0;
            end
            
            // ====== ID/EX Stage ======
            id_ex_op_type <= if_id_op_type;
            id_ex_rs1 <= if_id_rs1;
            id_ex_rs2 <= if_id_rs2;
            id_ex_rd <= if_id_rd;
            id_ex_alu_op <= alu_op;  // From input directly
            id_ex_rs1_data <= forwarded_rs1_data;
            id_ex_rs2_data <= forwarded_rs2_data;
            id_ex_imm <= if_id_imm;
            id_ex_byte_en <= byte_en;
            id_ex_valid <= if_id_valid;
            
            // ====== EX/MEM Stage ======
            ex_mem_op_type <= id_ex_op_type;
            ex_mem_rd <= id_ex_rd;
            ex_mem_alu_result <= alu_result;
            ex_mem_store_data <= id_ex_rs2_data;
            ex_mem_mem_addr <= id_ex_rs1_data + id_ex_imm;
            ex_mem_byte_en <= id_ex_byte_en;
            ex_mem_valid <= id_ex_valid;
            
            // ====== MEM/WB Stage ======
            mem_wb_op_type <= ex_mem_op_type;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_valid <= ex_mem_valid;
            
            // Memory access
            case (ex_mem_op_type)
                2'b11: begin  // STORE
                    memory[ex_mem_mem_addr[7:0]] <= ex_mem_store_data;
                    mem_wb_result <= ex_mem_alu_result;
                end
                2'b10: begin  // LOAD
                    mem_wb_result <= memory[ex_mem_mem_addr[7:0]];
                end
                default: begin  // ALU or NOP
                    mem_wb_result <= ex_mem_alu_result;
                end
            endcase
            
            // ====== Write Back Stage ======
            if (mem_wb_valid && mem_wb_op_type != 2'b00) begin
                if (mem_wb_rd != 0) begin
                    regs[mem_wb_rd] <= mem_wb_result;
                end
            end
        end
    end
    
    // ========================================================================
    // Continuous Output Assignment
    // ========================================================================
    always @(*) begin
        r1 = regs[1];
        r2 = regs[2];
        r3 = regs[3];
        r4 = regs[4];
        r5 = regs[5];
        r7 = regs[7];
        mem_out = memory[0];
    end

endmodule