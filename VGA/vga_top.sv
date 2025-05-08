module vga_top (
    // External clock (50 MHz) from your board
    input  wire clk_50,
    // Asynchronous reset pushbutton (active-high)
    input  wire rst_btn,
    
    // VGA outputs
    output wire hsync,
    output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue,
    
    // Optional outputs for debugging or syncing (VGA counters)
    output wire [9:0] hc_out,
    output wire [9:0] vc_out
);

    // ----------------------------------------------------------------
    // Parameter definitions for active display and downscaled resolution
    // ----------------------------------------------------------------
    localparam H_PIXELS   = 640;                // active horizontal pixels
    localparam V_PIXELS   = 480;                // active vertical pixels
    localparam SCALE      = 20;                 // blocking factor: each block is 20x20 pixels
    localparam DS_WIDTH   = H_PIXELS / SCALE;     // downscaled width (e.g., 640/20=32)
    localparam DS_HEIGHT  = V_PIXELS / SCALE;     // downscaled height (e.g., 480/20=24)
    localparam RAM_SIZE   = DS_WIDTH * DS_HEIGHT; // total number of blocks (e.g., 32*24=768)
    localparam ADDR_WIDTH = $clog2(RAM_SIZE);       // address width for RAM

    // ----------------------------------------------------------------
    // Instantiate the PLL: convert 50 MHz into a 25 MHz clock for VGA timing
    // ----------------------------------------------------------------
    wire vgaclk;
    vgaclk my_pll (
        .inclk0(clk_50),
        .c0(vgaclk)
    );

    // ----------------------------------------------------------------
    // Reset Synchronization: shift in the external reset (rst_btn)
    // ----------------------------------------------------------------
    reg [3:0] rst_shift;
    always @(posedge vgaclk) begin
        rst_shift <= {rst_shift[2:0], rst_btn};
    end
    // When the shift register holds all zeros, our synchronized reset is active
    wire rst_sync = (rst_shift == 4'b0000);

    // ----------------------------------------------------------------
    // VGA counters: these are generated inside the VGA module.
    // We use them both to drive the VGA read address and as inputs
    // to the graphics module.
    // ----------------------------------------------------------------
    wire [9:0] hc;
    wire [9:0] vc;

    // ----------------------------------------------------------------
    // Graphics Module: computes what pixel data should be written.
    // It outputs a write address, an 8-bit pixel color, and a write enable.
    // (The graphics module should be modified to provide these ports.)
    // ----------------------------------------------------------------
    wire [ADDR_WIDTH-1:0] write_addr;
    wire [7:0]            write_data;
    wire                  write_en;

    graphics graphics_inst (
        .hc(hc),
        .vc(vc),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_en(write_en)
    );


    wire [7:0] pixel_out;
    ping_pong_ram #(
        .H_PIXELS(H_PIXELS),
        .V_PIXELS(V_PIXELS),
        .SCALE(SCALE)
    ) ping_pong_inst (
        .clk(vgaclk),
        .hc(hc),
        .vc(vc),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_en(write_en),
        .pixel_out(pixel_out)
    );

    // ----------------------------------------------------------------
    // VGA Module: Reads pixel data from the ping-pong RAM.
    // Since the VGA module expects a 3:3:2 format (3-bit red, 3-bit green, 2-bit blue),
    // we extract bits from the 8-bit pixel_out accordingly.
    // ----------------------------------------------------------------
    vga vga_inst (
        .vgaclk(vgaclk),
        .rst(rst_sync),
        .input_red(pixel_out[7:5]),   // Convert 8-bit pixel to 3-bit red input
        .input_green(pixel_out[4:2]), // Convert 8-bit pixel to 3-bit green input
        .input_blue(pixel_out[1:0]),  // Convert 8-bit pixel to 2-bit blue input
        .hc_out(hc),
        .vc_out(vc),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );

    // ----------------------------------------------------------------
    // Optional: expose VGA counters to top-level outputs for debugging.
    // ----------------------------------------------------------------
    assign hc_out = hc;
    assign vc_out = vc;

endmodule
