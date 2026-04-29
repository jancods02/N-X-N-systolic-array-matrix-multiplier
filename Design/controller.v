`timescale 1ns / 1ps

module controller #(parameter N = 8)(
    input clk, rst, start,
    input [N - 1:0] a_empty, b_empty, 
    output [N - 1:0] rd,
    output reg done
);
    reg [N+3:0] count; 
    reg [1:0] state;
    localparam IDLE=0, RUN=1, DONE=2;

    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : GEN_RD
            assign rd[k] = (state == RUN) && (count >= k && count < (k + N));
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            count <= 0; 
            done <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0; 
                    count <= 0; 
                    if (start) state <= RUN; 
                end

                RUN: begin
                    // We increase this to 4*N to ensure all data leaves the array
                    if (count >= (4 * N + 4)) begin 
                        state <= DONE; 
                        count <= 0; 
                    end else begin
                        count <= count + 1; 
                    end
                end

                DONE: begin
                    done <= 1; 
                    state <= IDLE; 
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule