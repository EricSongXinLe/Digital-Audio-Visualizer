package fft_pkg;
  parameter int WIDTH = 32;            // packed {Re,Im}
  parameter int HALF  = WIDTH/2;       // 16
  localparam logic [WIDTH-1:0] W0 = 32'h7FFF_0000; // 1 + 0 j
  localparam logic [WIDTH-1:0] W1 = 32'h0000_8000; // 0 – 1 j
endpackage
import fft_pkg::*;

// ------------------------------------------------------------
module butterfly #(
    parameter int WIDTH = fft_pkg::WIDTH,
    parameter int HALF  = WIDTH/2
) (
    input  logic signed [WIDTH-1:0] A ,
    input  logic signed [WIDTH-1:0] B ,
    input  logic signed [WIDTH-1:0] W ,
    output logic signed [WIDTH-1:0] sum ,
    output logic signed [WIDTH-1:0] diff
);
    // split packed words
    logic signed [HALF-1:0] A_re, A_im, B_re, B_im, W_re, W_im;
    assign {A_re, A_im} = A;
    assign {B_re, B_im} = B;
    assign {W_re, W_im} = W;

    // 16×16-bit products → 32-bit
    logic signed [2*HALF-1:0] mult_re, mult_im;   // 32 bits
    assign mult_re = B_re*W_re - B_im*W_im;        // Q1.30
    assign mult_im = B_re*W_im + B_im*W_re;

    // scale back to Q1.15 with arithmetic shift (keeps sign)
    logic signed [HALF-1:0] BW_re, BW_im;
    assign BW_re = mult_re >>> 15;   
    assign BW_im = mult_im >>> 15;

    // outputs
    assign sum  = {A_re + BW_re,  A_im + BW_im};
    assign diff = {A_re - BW_re,  A_im - BW_im};
endmodule
