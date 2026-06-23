// ============================================================================
// ALU (Arithmetic Logic Unit) Module
// Supports: +, -, *, /, &
// ============================================================================

module alu (
    input [15:0] operand1,
    input [15:0] operand2,
    input [2:0] alu_op,      // 000: +, 001: -, 010: *, 011: /, 100: &
    output reg [15:0] result
);

    always @(*) begin
        case (alu_op)
            3'b000: result = operand1 + operand2;      // ADD
            3'b001: result = operand1 - operand2;      // SUB
            3'b010: result = operand1 * operand2;      // MUL
            3'b011: result = (operand2 != 0) ? (operand1 / operand2) : 16'h0000;  // DIV
            3'b100: result = operand1 & operand2;      // AND
            default: result = 16'h0000;
        endcase
    end

endmodule