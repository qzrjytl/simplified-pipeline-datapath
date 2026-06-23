// ============================================================================
// Register File Module
// 8 registers x 16 bits
// ============================================================================

module register_file (
    input clk,
    input reset,
    
    // Read ports (asynchronous)
    input [2:0] read_addr1,
    input [2:0] read_addr2,
    output [15:0] read_data1,
    output [15:0] read_data2,
    
    // Write port (synchronous)
    input [2:0] write_addr,
    input [15:0] write_data,
    input write_enable
);

    reg [15:0] regs [0:7];
    
    // Initialize registers
    initial begin
        regs[0] <= 16'h0000;  // R0 (always 0)
        regs[1] <= 16'h0004;  // R1
        regs[2] <= 16'h0006;  // R2
        regs[3] <= 16'h1234;  // R3
        regs[4] <= 16'h0000;  // R4
        regs[5] <= 16'h0000;  // R5
        regs[6] <= 16'h0000;  // R6
        regs[7] <= 16'h00FF;  // R7
    end
    
    // Asynchronous read
    assign read_data1 = regs[read_addr1];
    assign read_data2 = regs[read_addr2];
    
    // Synchronous write
    always @(posedge clk) begin
        if (reset) begin
            regs[0] <= 16'h0000;
            regs[1] <= 16'h0004;
            regs[2] <= 16'h0006;
            regs[3] <= 16'h1234;
            regs[4] <= 16'h0000;
            regs[5] <= 16'h0000;
            regs[6] <= 16'h0000;
            regs[7] <= 16'h00FF;
        end
        else if (write_enable && write_addr != 0) begin
            regs[write_addr] <= write_data;
        end
    end

endmodule