// ============================================================================
// Memory Module
// 256 x 16-bit memory
// ============================================================================

module memory (
    input clk,
    input [7:0] addr,
    input [15:0] write_data,
    input write_enable,
    output [15:0] read_data
);

    reg [15:0] mem [0:255];
    
    // Initialize memory
    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] <= 16'h0000;
        end
    end
    
    // Asynchronous read
    assign read_data = mem[addr];
    
    // Synchronous write
    always @(posedge clk) begin
        if (write_enable) begin
            mem[addr] <= write_data;
        end
    end

endmodule