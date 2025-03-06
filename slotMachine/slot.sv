module slot(
    input logic clk,
    input logic running,  // When high, the slot’s value updates
    input logic rst,
    output logic [3:0] number
);
  logic [3:0] lfsr;
  
  always_ff @(posedge clk) begin
    if (rst)
      lfsr <= 4'b0101;  // Seed value
    else if (running)
      lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]};
  end
  
  assign number = lfsr;
endmodule
