// ============================================================================
// Testbench for Five-Stage Pipeline Datapath
// ============================================================================

`timescale 1ns / 1ps

module pipeline_datapath_tb ();

    // Clock and reset
    reg clk;
    reg reset;
    
    // Instruction signals
    reg valid;
    reg [1:0] op_type;
    reg [2:0] rs1, rs2, rd;
    reg [15:0] imm;
    reg [2:0] alu_op;
    reg [1:0] byte_en;
    
    // Monitor signals
    wire [15:0] r1, r2, r3, r4, r5, r7;
    wire [15:0] mem_out;
    
    // Instantiate DUT
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
    always #5 clk = ~clk;
    
    // Test procedure
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pipeline_datapath_tb);
        
        // Initialize
        clk = 0;
        reset = 1;
        valid = 0;
        op_type = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        imm = 0;
        alu_op = 0;
        byte_en = 0;
        
        #10 reset = 0;
        
        // Test Case 1: R4 = R1 + R2
        $display("\n=== Test Case 1: R4 = R1 + R2 ===");
        @(posedge clk);
        valid = 1;
        op_type = 2'b01;   // ALU
        rs1 = 3'd1;        // R1
        rs2 = 3'd2;        // R2
        rd = 3'd4;         // R4
        alu_op = 3'b000;   // ADD
        
        @(posedge clk);
        valid = 0;
        repeat(4) @(posedge clk);
        $display("R4 = 0x%h (expected 0x000a)", r4);
        
        // Test Case 2: R5 = Mem[R1+0]
        $display("\n=== Test Case 2: R5 = Mem[R1+0] (LOAD) ===");
        @(posedge clk);
        valid = 1;
        op_type = 2'b10;   // LOAD
        rs1 = 3'd1;        // R1 (address = 0x0004)
        rd = 3'd5;         // R5
        imm = 16'h0000;
        
        @(posedge clk);
        valid = 0;
        repeat(5) @(posedge clk);
        $display("R5 = 0x%h", r5);
        
        // Test Case 3: Mem[R1+0] = R3 (STORE)
        $display("\n=== Test Case 3: Mem[R1+0] = R3 (STORE) ===");
        @(posedge clk);
        valid = 1;
        op_type = 2'b11;   // STORE
        rs1 = 3'd1;        // R1 (address)
        rs2 = 3'd3;        // R3 (data)
        imm = 16'h0000;
        
        @(posedge clk);
        valid = 0;
        repeat(5) @(posedge clk);
        $display("Memory write completed");
        
        // Test Case 4: R6 = R4 - R2
        $display("\n=== Test Case 4: R6 = R4 - R2 ===");
        @(posedge clk);
        valid = 1;
        op_type = 2'b01;   // ALU
        rs1 = 3'd4;        // R4
        rs2 = 3'd2;        // R2
        rd = 3'd6;         // R6
        alu_op = 3'b001;   // SUB
        
        @(posedge clk);
        valid = 0;
        repeat(4) @(posedge clk);
        $display("R6 = 0x%h (expected 0x0004)", r6);
        
        // Final state
        $display("\n=== Final Register State ===");
        $display("R1 = 0x%h", r1);
        $display("R2 = 0x%h", r2);
        $display("R3 = 0x%h", r3);
        $display("R4 = 0x%h", r4);
        $display("R5 = 0x%h", r5);
        $display("R7 = 0x%h", r7);
        
        #50 $finish;
    end

endmodule