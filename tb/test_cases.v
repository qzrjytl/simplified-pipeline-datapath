// ============================================================================
// Test Cases for Five-Stage Pipeline Datapath
// Implements the test scenario from design specification
// ============================================================================

`timescale 1ns / 1ps

module test_cases ();

    // Test parameters
    parameter CLK_PERIOD = 10;  // 10ns clock period
    
    // Signals
    reg clk;
    reg reset;
    reg valid;
    reg [1:0] op_type;
    reg [2:0] rs1, rs2, rd;
    reg [15:0] imm;
    reg [2:0] alu_op;
    reg [1:0] byte_en;
    
    wire [15:0] r1, r2, r3, r4, r5, r7;
    wire [15:0] mem_out;
    
    pipeline_datapath dut (
        .clk(clk),
        .reset(reset),
        .valid(valid),
        .op_type(op_type),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),
        .alu_op(alu_op),
        .byte_en(byte_en),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4),
        .r5(r5),
        .r7(r7),
        .mem_out(mem_out)
    );
    
    // Clock generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;
    
    // Test tasks
    task send_instruction;
        input [1:0] op;
        input [2:0] r_s1, r_s2, r_d;
        input [2:0] alu_code;
        input [15:0] immediate;
        begin
            @(posedge clk);
            valid = 1;
            op_type = op;
            rs1 = r_s1;
            rs2 = r_s2;
            rd = r_d;
            alu_op = alu_code;
            imm = immediate;
            @(posedge clk);
            valid = 0;
        end
    endtask
    
    task wait_cycles;
        input [15:0] cycles;
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask
    
    task check_register;
        input [15:0] expected;
        input [15:0] actual;
        input [8*20:1] name;
        begin
            if (expected === actual) begin
                $display("[PASS] %s = 0x%h", name, actual);
            end else begin
                $display("[FAIL] %s: expected 0x%h, got 0x%h", name, expected, actual);
            end
        end
    endtask
    
    // Main test
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, test_cases);
        
        // Initialize
        reset = 1;
        valid = 0;
        op_type = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        imm = 0;
        alu_op = 0;
        byte_en = 0;
        
        wait_cycles(2);
        reset = 0;
        
        $display("\n========================================");
        $display("  Five-Stage Pipeline Datapath Tests");
        $display("========================================\n");
        
        // ===== Test Scenario from Spec =====
        $display("\n--- Initialization Check ---");
        check_register(16'h0004, r1, "R1");
        check_register(16'h0006, r2, "R2");
        check_register(16'h1234, r3, "R3");
        check_register(16'h00FF, r7, "R7");
        
        // Week 1, Cycle 1: R4 = R1 + R2
        $display("\n--- Week 1, Cycle 1: R4 = R1 + R2 (ALU) ---");
        send_instruction(2'b01, 3'd1, 3'd2, 3'd4, 3'b000, 16'h0000);
        wait_cycles(4);
        check_register(16'h000A, r4, "R4");
        
        // Week 1, Cycle 2: Mem[R1+0] = R3 (STORE)
        $display("\n--- Week 1, Cycle 2: Mem[R1+0] = R3 (STORE) ---");
        send_instruction(2'b11, 3'd1, 3'd3, 3'd0, 3'b000, 16'h0000);
        wait_cycles(5);
        
        // Week 1, Cycle 3: R5 = Mem[R1+0] (LOAD)
        $display("\n--- Week 1, Cycle 3: R5 = Mem[R1+0] (LOAD) ---");
        send_instruction(2'b10, 3'd1, 3'd0, 3'd5, 3'b000, 16'h0000);
        wait_cycles(5);
        check_register(16'h1234, r5, "R5");
        
        // NOP cycles
        $display("\n--- NOP cycles (4, 5, 6) ---");
        send_instruction(2'b00, 3'd0, 3'd0, 3'd0, 3'b000, 16'h0000);
        wait_cycles(3);
        send_instruction(2'b00, 3'd0, 3'd0, 3'd0, 3'b000, 16'h0000);
        wait_cycles(3);
        send_instruction(2'b00, 3'd0, 3'd0, 3'd0, 3'b000, 16'h0000);
        wait_cycles(3);
        
        // Week 1, Cycle 7: R6 = R4 - R2
        $display("\n--- Week 1, Cycle 7: R6 = R4 - R2 (SUB) ---");
        send_instruction(2'b01, 3'd4, 3'd2, 3'd6, 3'b001, 16'h0000);
        wait_cycles(4);
        check_register(16'h0004, r6, "R6");
        
        // Final check
        $display("\n========================================");
        $display("  Final Register State");
        $display("========================================");
        $display("R1 = 0x%h", r1);
        $display("R2 = 0x%h", r2);
        $display("R3 = 0x%h", r3);
        $display("R4 = 0x%h", r4);
        $display("R5 = 0x%h", r5);
        $display("R7 = 0x%h", r7);
        $display("========================================\n");
        
        #100 $finish;
    end

endmodule