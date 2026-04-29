`timescale 1ns / 1ps

module tb_systolic_array;
    parameter N = 8;
    parameter DATA_WIDTH = 8;
    parameter OUT_WIDTH = 16; 

    reg clk, rst, start;
    reg [DATA_WIDTH-1:0] din;
    reg [N-1:0] external_row_wr, external_col_wr;

    wire done;
    wire [(N*N)*OUT_WIDTH-1 : 0] C_flattened; 
    
    // --- STORAGE FOR PRINTING ---
    reg [DATA_WIDTH-1:0] A_matrix [0:N-1][0:N-1]; // Added to store A
    reg [DATA_WIDTH-1:0] B_matrix [0:N-1][0:N-1]; // Added to store B
    reg [OUT_WIDTH-1:0]  C_matrix [0:N-1][0:N-1];
    wire [N-1:0] row_full, col_full;
   
    integer i, j, k;

    systolic_array_top #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk), .rst(rst), .start(start), .din(din),
        .external_row_wr(external_row_wr),
        .external_col_wr(external_col_wr),
        .done(done),
        .C_flattened(C_flattened) 
    );
    assign row_full = dut.row_full;
    assign col_full = dut.col_full;
    // Unflattening logic for C
    always @(*) begin
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                C_matrix[i][j] = C_flattened[((i*N) + j)*OUT_WIDTH +: OUT_WIDTH];
            end
        end
    end

    always #5 clk = ~clk;

    task run_matrix_test;
        input [8*32:1] test_name;
        begin
            $display("\n========================================");
            $display(" TEST: %s", test_name);
            $display("========================================");
            
            // Print Matrix A
            $display("--- Input Matrix A ---");
            for (i = 0; i < N; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) $write("%d\t", A_matrix[i][j]);
                $write("\n");
            end

            // Print Matrix B
            $display("\n--- Input Matrix B ---");
            for (i = 0; i < N; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) $write("%d\t", B_matrix[i][j]);
                $write("\n");
            end

            @(posedge clk); start = 1;
            @(posedge clk); start = 0;
            wait(done == 1);
            
            // Print Matrix C
            $display("\n--- Result Matrix C ---");
            for (i = 0; i < N; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) $write("%d\t", C_matrix[i][j]);
                $write("\n");
            end
            $display("========================================\n");
            #50; 
        end
    endtask

    initial begin
        $dumpfile("systolic.vcd"); $dumpvars(0, tb_systolic_array);
        clk = 0; rst = 1; start = 0; din = 0; 
        external_row_wr = 0; external_col_wr = 0;
        #20 rst = 0;

        // Test Case -1
        $display("[%0t] Loading Set 1: Identity...", $time);
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                @(posedge clk); 
                if (row_full !=1)
                  din = (i+1); 
                else
                  rst = 0;
                A_matrix[i][j] = din; // Capture for printing
                external_row_wr = (1 << i);
            end
            @(posedge clk); external_row_wr = 0;
        end
        for (j = 0; j < N; j = j + 1) begin
            for (i = 0; i < N; i = i + 1) begin
                @(posedge clk);
                if (col_full !=1) 
                  din = (i == j) ? 8'd1 : 8'd0; 
                else
                  rst = 0;
                B_matrix[i][j] = din; // Capture for printing
                external_col_wr = (1 << j);
            end
            @(posedge clk); external_col_wr = 0;
        end
        run_matrix_test("Identity_Test");

        // Test Case -2
        #20 rst = 1; #20 rst = 0;
        $display("[%0t] Loading Set 2: Max Stress...", $time);
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                @(posedge clk); 
                if (row_full !=1 && col_full != 1)
                  din = 8'h5A;
                else
                  rst = 0; 
                A_matrix[i][j] = din;
                B_matrix[i][j] = din;
                external_row_wr = (1 << i);
                external_col_wr = (1 << j);
            end
            @(posedge clk); external_row_wr = 0; external_col_wr = 0;
        end
        run_matrix_test(" Stress Test");

        // Test Case - 3
        #20 rst = 1; #20 rst = 0;
        $display("[%0t] Loading Set 3: Incremental...", $time);
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                @(posedge clk); 
                if(row_full != 1)
                  din = (i+1);
                else
                  rst = 0; 
                A_matrix[i][j] = din;
                external_row_wr = (1 << i);
            end
            @(posedge clk); external_row_wr = 0;
        end
        for (j = 0; j < N; j = j + 1) begin
            for (i = 0; i < N; i = i + 1) begin
                @(posedge clk);
                if(col_full != 1) 
                  din = (2*i);
                else
                  rst = 0;
                B_matrix[i][j] = din;
                external_col_wr = (1 << j);
            end
            @(posedge clk); external_col_wr = 0;
        end
        run_matrix_test("Matrix 1 Test");
        
        // Test Case - 4
        #20 rst = 1; #20 rst = 0;
        $display("[%0t] Loading Set 4: Incremental...", $time);
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                @(posedge clk); 
                if(row_full != 1)
                  din = (i+1); 
                else 
                  rst = 0;
                A_matrix[i][j] = din;
                external_row_wr = (1 << i);
            end
            @(posedge clk); external_row_wr = 0;
        end
        for (j = 0; j < N; j = j + 1) begin
            for (i = 0; i < N; i = i + 1) begin
                @(posedge clk); 
                if(col_full != 1)
                  din = (3*(i+1)); 
                else
                  rst = 0;
                B_matrix[i][j] = din;
                external_col_wr = (1 << j);
            end
            @(posedge clk); external_col_wr = 0;
        end
        run_matrix_test("Matrix Test -2");

        // Toggle coverage test
        for (k = 0; k < 100; k = k + 1) begin
            @(posedge clk);
            if(row_full != 1 && col_full != 1)
            din = $random;
            else
              rst = 0;
            external_row_wr = $random;
            external_col_wr = $random;
        end

        $display("\nSimulation Complete.");
        $finish;
    end

endmodule