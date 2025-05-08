module ping_pong_ram #(
    // Parameters for active VGA and downscaled (blocked) image
    parameter H_PIXELS   = 640,                // active horizontal pixels
    parameter V_PIXELS   = 480,                // active vertical pixels
    parameter SCALE      = 20,                 // blocking factor (each block is 20x20)
    parameter DS_WIDTH   = H_PIXELS / SCALE,     // downscaled width (e.g., 640/20=32)
    parameter DS_HEIGHT  = V_PIXELS / SCALE,     // downscaled height (e.g., 480/20=24)
    parameter RAM_SIZE   = DS_WIDTH * DS_HEIGHT, // total number of blocked pixels (e.g., 32*24=768)
    parameter ADDR_WIDTH = $clog2(RAM_SIZE)       // address width needed to index RAM_SIZE locations
)
(
    input  logic                   clk,         // clock signal (synchronized to VGA clock)
    input  logic [9:0]             hc,          // VGA horizontal counter
    input  logic [9:0]             vc,          // VGA vertical counter

    // Write port inputs (from your graphics controller)
    input  logic [ADDR_WIDTH-1:0]  write_addr,  // Address to write pixel data
    input  logic [7:0]             write_data,  // 8-bit pixel data (color) to write
    input  logic                   write_en,    // Write enable (when asserted, a write occurs)

    // Output: pixel data read from the current read buffer for VGA
    output logic [7:0]             pixel_out
);

  // Two buffers: one used for reading, the other for writing.
  // These mimic asynchronous RAMs (for now implemented as arrays of registers)
  logic [7:0] buffer0 [0:RAM_SIZE-1];
  logic [7:0] buffer1 [0:RAM_SIZE-1];

  // A 1-bit register to choose which buffer is being read.
  // current_buffer == 0: read from buffer0, write to buffer1.
  // current_buffer == 1: read from buffer1, write to buffer0.
  logic current_buffer;

  // ----------------------------------------------------------------
  // Calculate the read address based on the VGA counters.
  // We downscale the hc and vc values by the SCALE factor.
  // (For example, with SCALE==20, if hc==100 then xpos = 100/20 = 5).
  // Then, we form a linear address for the blocked pixel:
  //       address = (vc / SCALE) * DS_WIDTH + (hc / SCALE)
  // ----------------------------------------------------------------
  logic [ADDR_WIDTH-1:0] read_addr;
  assign read_addr = (vc / SCALE) * DS_WIDTH + (hc / SCALE);

  // ----------------------------------------------------------------
  // Write logic: Update the buffer that is *not* used for reading.
  // The graphics controller supplies a write address and data.
  // We assume write_en is high when a write is requested.
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    if (write_en) begin
      if (current_buffer == 0) begin
        buffer1[write_addr] <= write_data;
      end else begin
        buffer0[write_addr] <= write_data;
      end
    end
  end

  // ----------------------------------------------------------------
  // Read logic: Combinationally select the pixel value from the read buffer.
  // This value is driven to the VGA system.
  // ----------------------------------------------------------------
  always_comb begin
    if (current_buffer == 0)
      pixel_out = buffer0[read_addr];
    else
      pixel_out = buffer1[read_addr];
  end

  // ----------------------------------------------------------------
  // Buffer switching logic:
  // When both hc and vc equal zero (start-of-frame), flip the current_buffer.
  // This ensures that writing happens into the now-idle buffer.
  // The switching is done synchronously on the clock edge.
  // ----------------------------------------------------------------
  always_ff @(posedge clk) begin
    // Detect start-of-frame condition (both counters are zero)
    if (hc == 10'd0 && vc == 10'd0) begin
      current_buffer <= ~current_buffer;
    end
  end

endmodule
