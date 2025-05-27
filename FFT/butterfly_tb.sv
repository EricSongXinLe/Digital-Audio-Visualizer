module butterfly_tb (output temp);
  import fft_pkg::*;
  logic signed [WIDTH-1:0] A, B;
  logic signed [WIDTH-1:0] out0, out1;
  
  assign temp=0;

  // instance with W1
  butterfly bf (.A(A), .B(B), .W(W1), .sum(out0), .diff(out1));

  initial begin
    A = {16'sd100, 16'sd50};   // 100 + 50j
    B = {16'sd200, -16'sd75};  // 200 - 75j
    #1; $displayh(out0, out1);  
    $finish;
  end
endmodule
