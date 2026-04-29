`timescale 1ns / 1ps

module PE #(parameter WIDTH = 32) (
    input clk, rst,
    input [WIDTH-1:0] inp_north, inp_west,
    output reg [WIDTH-1:0] outp_south, outp_east,
    output reg [(2*WIDTH)-1:0] result
);
    always @(posedge clk) begin
        if (rst) begin
            result <= 0;
            outp_south <= 0;
            outp_east <= 0;
        end else begin
            result <= result + (inp_north * inp_west);
            outp_south <= inp_north;
            outp_east <= inp_west;
        end
    end
endmodule