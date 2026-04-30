`timescale 1ns / 1ps

module systolic_array_top #(
    parameter N = 8,
    parameter DATA_WIDTH = 8
)(
    input clk, rst, start,
    input [DATA_WIDTH-1:0] din,                // Manual data input
    input [N-1:0] external_row_wr,             // Manual row FIFO write enable
    input [N-1:0] external_col_wr,             // Manual col FIFO write enable
    output done,
    // Flattened Output Vector: (8*8) * 64 bits = 4096 bits
    output [(N*N)*(2*DATA_WIDTH)-1 : 0] C_flattened 
);

    // Internal Wires
    wire [N-1:0] fifo_rd;
    wire [N-1:0] row_empty, col_empty, row_full, col_full;
    
    wire [DATA_WIDTH-1:0] horizontal_wires [0:N][0:N];
    wire [DATA_WIDTH-1:0] vertical_wires   [0:N][0:N];
    
    // Internal 2D array to collect PE results before flattening
    wire [(2*DATA_WIDTH)-1:0] result_internal [0:N-1][0:N-1];

    // controller
    controller #(.N(N)) ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a_empty(row_empty),
        .b_empty(col_empty),
        .rd(fifo_rd),
        .done(done)
    );


    genvar r, c;
    generate
        for (r = 0; r < N; r = r + 1) begin : ROW_GEN
            
            // Row FIFOs (Matrix A)
            // Depth must be at least N to hold a full row for N=8
            FIFO #(.WIDTH(DATA_WIDTH), .DEPTH(N)) fifo_a (
                .clk(clk), .rst(rst),
                .wr(external_row_wr[r]),
                .rd(fifo_rd[r]),
                .din(din),
                .dout(horizontal_wires[r][0]),
                .full(row_full[r]),
                .empty(row_empty[r])
            );

            // Column FIFOs (Matrix B)
            FIFO #(.WIDTH(DATA_WIDTH), .DEPTH(N)) fifo_b (
                .clk(clk), .rst(rst),
                .wr(external_col_wr[r]), 
                .rd(fifo_rd[r]),
                .din(din),
                .dout(vertical_wires[0][r]),
                .full(col_full[r]),
                .empty(col_empty[r])
            );

            for (c = 0; c < N; c = c + 1) begin : COL_GEN
                // Instantiate Processing Element
                PE #(.WIDTH(DATA_WIDTH)) pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .inp_north(vertical_wires[r][c]),
                    .inp_west(horizontal_wires[r][c]),
                    .outp_south(vertical_wires[r+1][c]),
                    .outp_east(horizontal_wires[r][c+1]),
                    .result(result_internal[r][c])
                );

                assign C_flattened[((r*N) + c)*2*DATA_WIDTH +: 2*DATA_WIDTH] = result_internal[r][c];
            end
        end
    endgenerate

endmodule