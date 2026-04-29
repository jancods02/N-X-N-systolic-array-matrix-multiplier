`timescale 1ns / 1ps

module FIFO #(parameter WIDTH = 32, DEPTH = 16)(
    input clk, rst, wr, rd,
    input [WIDTH-1:0] din,       // Changed from [7:0]
    output reg [WIDTH-1:0] dout,  // Changed from [7:0]
    output empty, full
);
  
  // Pointers for write and read operations
  reg [$clog2(DEPTH) - 1:0] wptr = 0, rptr = 0;
  
  // Counter for tracking the number of elements in the FIFO
  reg [$clog2(DEPTH):0] cnt = 0;
  
  // Memory array to store data
  reg [WIDTH - 1:0] mem [DEPTH - 1:0];
 
always @(posedge clk) begin
    if (rst) begin
        wptr <= 0;
        rptr <= 0;
        cnt  <= 0;
        dout <= 0; // Explicitly reset dout to 0 to avoid 'X'
    end else begin
        if (wr && !full) begin
            mem[wptr] <= din;
            wptr <= wptr + 1;
            cnt  <= cnt + 1;
        end
        if (rd && !empty) begin
            dout <= mem[rptr];
            rptr <= rptr + 1;
            cnt  <= cnt - 1;
        end else if (!rd) begin
            dout <= 0; // Drive 0 when not reading to keep PE inputs clean
        end
    end
end
 
  // Determine if the FIFO is empty or full
  assign empty = (cnt == 0) ? 1'b1 : 1'b0;
  assign full  = (cnt == DEPTH) ? 1'b1 : 1'b0;
 
endmodule