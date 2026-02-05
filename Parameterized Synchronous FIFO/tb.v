`timescale 1ns/1ps

module tb_sync_fifo;

  parameter DEPTH = 8;
  parameter DATA_WIDTH = 8;

  reg clk;
  reg rst_n;
  reg w_en;
  reg r_en;
  reg [DATA_WIDTH-1:0] data_in;

  wire [DATA_WIDTH-1:0] data_out;
  wire full;
  wire empty;

  // DUT instantiation
  sync_fifo #(
    .DEPTH(DEPTH),
    .DATA_WIDTH(DATA_WIDTH)) 
    dut(
    .clk(clk),
    .rst_n(rst_n),
    .w_en(w_en),
    .r_en(r_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
  );

  // Clock generation (10 ns period)
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst_n = 0;
    w_en = 0;
    r_en = 0;
    data_in = 0;

    // Apply reset
    #20;
    rst_n = 1;

    $display("---- Reset Deasserted ----");

    // Write DEPTH elements
    repeat (DEPTH) begin
      @(posedge clk);
      if (!full) begin
        w_en = 1;
        data_in = $random;
        $display("WRITE: data_in = %0d", data_in);
      end
    end

    @(posedge clk);
    w_en = 0;

    $display("---- FIFO should be FULL now ----");

    // Try writing when full
    @(posedge clk);
    w_en = 1;
    data_in = 8'hAA;
    @(posedge clk);
    w_en = 0;

    // Read DEPTH elements
    repeat (DEPTH) begin
      @(posedge clk);
      if (!empty) begin
        r_en = 1;
        $display("READ: data_out = %0d", data_out);
      end
    end

    @(posedge clk);
    r_en = 0;

    $display("---- FIFO should be EMPTY now ----");

    // Try reading when empty
    @(posedge clk);
    r_en = 1;
    @(posedge clk);
    r_en = 0;

    #20;
    $display("---- Simulation Finished ----");
    $finish;
  end

endmodule
