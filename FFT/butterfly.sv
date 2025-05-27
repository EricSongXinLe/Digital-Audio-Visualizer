// file: butterfly.sv
package fft_pkg;
  parameter int WIDTH = 32;             
  parameter int HALF  = WIDTH/2;
  // packed complex constants (Re|Im)
  localparam logic [WIDTH-1:0] W0 = 32'h7FFF_0000; // 1 + 0j
  localparam logic [WIDTH-1:0] W1 = 32'h0000_8000; // 0 - 1j
endpackage
import fft_pkg::*;

// -------------------------------------------
module butterfly #(
    parameter int WIDTH = fft_pkg::WIDTH,
    parameter int HALF  = WIDTH/2
) (
    input  logic signed [WIDTH-1:0] A ,
    input  logic signed [WIDTH-1:0] B ,
    input  logic signed [WIDTH-1:0] W ,   // twiddle
    output logic signed [WIDTH-1:0] sum , // A + B*W
    output logic signed [WIDTH-1:0] diff  // A - B*W
);
    // --- split inputs into real / imag halves
    logic signed [HALF-1:0] A_re, A_im, B_re, B_im, W_re, W_im;
    assign {A_re, A_im} = A;
    assign {B_re, B_im} = B;
    assign {W_re, W_im} = W;

    logic signed [2*HALF:0] mult_re, mult_im; // 33 bits
    assign mult_re = B_re*W_re - B_im*W_im;  
    assign mult_im = B_re*W_im + B_im*W_re;

    logic signed [HALF-1:0] BW_re, BW_im;
    assign BW_re = mult_re[2*HALF:15];  // keep bits [31:15]
    assign BW_im = mult_im[2*HALF:15];

    // --- outputs
    assign sum  = {A_re + BW_re,  A_im + BW_im};
    assign diff = {A_re - BW_re,  A_im - BW_im};
endmodule
