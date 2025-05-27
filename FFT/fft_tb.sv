`timescale 1ns/1ns

module fft_tb(output tmp);

  import fft_pkg::*;
	assign tmp = 0;
	
	reg clk;
	logic rst;
 

  logic                    start;
  logic signed [WIDTH-1:0] in  [3:0];
  logic signed [WIDTH-1:0] out [3:0];
  logic                    valid;


 initial begin
  clk  <= 0;
  rst  <= 1'b1;
        // Apply inputs and pulse start
    in[0] = {16'sd100 , 16'sd0};
    in[1] = {16'sd150 , 16'sd0};
    in[2] = {16'sd200 , 16'sd0};
    in[3] = {16'sd250 , 16'sd0};
	 #10 rst <= 0;
	 start <= 1;
	 #100 $stop;
  end

  always begin
	#5 clk <= ~clk;
	end

  fft_top dut (
    .clk   (clk),
    .rst   (rst),
    .start (start),
    .in    (in),
    .out   (out),
    .valid (valid)
  );



endmodule
