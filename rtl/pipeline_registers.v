// ============================================================================
// Pipeline Registers Module
// Implements IF/ID, ID/EX, EX/MEM, MEM/WB pipeline registers
// ============================================================================

module pipeline_registers (
    input clk,
    input reset,
    input flush,
    
    // IF/ID Register
    input [31:0] if_instr,
    output reg [31:0] ifid_instr,
    
    // ID/EX Register
    input [95:0] id_control,
    input [47:0] id_data,
    output reg [95:0] idex_control,
    output reg [47:0] idex_data,
    
    // EX/MEM Register
    input [47:0] ex_control,
    input [31:0] ex_result,
    output reg [47:0] exmem_control,
    output reg [31:0] exmem_result,
    
    // MEM/WB Register
    input [31:0] mem_control,
    input [31:0] mem_data,
    output reg [31:0] memwb_control,
    output reg [31:0] memwb_data
);

    always @(posedge clk) begin
        if (reset || flush) begin
            ifid_instr <= 0;
            idex_control <= 0;
            idex_data <= 0;
            exmem_control <= 0;
            exmem_result <= 0;
            memwb_control <= 0;
            memwb_data <= 0;
        end
        else begin
            ifid_instr <= if_instr;
            idex_control <= id_control;
            idex_data <= id_data;
            exmem_control <= ex_control;
            exmem_result <= ex_result;
            memwb_control <= mem_control;
            memwb_data <= mem_data;
        end
    end

endmodule