`timescale 1ns / 1ps

module clock_gate (
    input clk,    
    input en,     
    input te,    
    output gclk   
);
    reg latch_en;

    always @(clk or en or te) begin
        if (!clk)
            latch_en <= en | te;
    end

    assign gclk = clk & latch_en;
endmodule