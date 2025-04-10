module top (
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
    
    // Optional outputs: horizontal and vertical counters from the VGA module
    output wire [9:0] hc_out,
    output wire [9:0] vc_out
);

    //-------------------------------------------------------------------------
    // 1. Instantiate the PLL
    //   This PLL converts the 50 MHz input clock to a 25 MHz VGA clock.
    //   The PLL was generated using Quartus’s ALTPLL IP and is already added.
    //-------------------------------------------------------------------------
    wire vgaclk;    // 25 MHz clock for VGA
    
    // Instantiate the PLL module.
    // Note: Replace "vgaclk" with the actual name of the PLL module if it differs.
    vgaclk my_pll (
        .inclk0(clk_50),
        .c0(vgaclk)
    );
    
    //-------------------------------------------------------------------------
    // 2. Reset Synchronization
    //    To properly reset the VGA module, we filter the external reset through
    //    a shift register to synchronize it to the VGA clock domain.
    //-------------------------------------------------------------------------
    reg [3:0] rst_shift;
    always @(posedge vgaclk) begin
        // Shifting in the external reset (rst_btn) over several cycles
        rst_shift <= {rst_shift[2:0], rst_btn};
    end
    // Use the last bit of the shift register as the synchronized reset signal.
    wire rst_sync = rst_shift[3];
    
    //-------------------------------------------------------------------------
    // 3. Instantiate the VGA Module
    //    For testing purposes, we drive the VGA module with constant color
    //    values. You can modify these signals or replace them with a graphics
    //    generator in your design.
    //-------------------------------------------------------------------------
    // Example test pattern: constant color (bright red, for instance)
    wire [2:0] test_red   = 3'b111;  // maximum red intensity
    wire [2:0] test_green = 3'b000;  // no green
    wire [1:0] test_blue  = 2'b00;   // no blue
    
    vga vga_inst (
        .vgaclk(vgaclk),
        .rst(rst_sync),
        .input_red(test_red),
        .input_green(test_green),
        .input_blue(test_blue),
        .hc_out(hc_out),
        .vc_out(vc_out),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );

    //-------------------------------------------------------------------------
    // 4. Pin Planning (Reminder)
    //    Be sure to assign the FPGA pins for your external clock, pushbutton,
    //    and VGA outputs (hsync, vsync, red, green, blue) in your Quartus
    //    pin planner file.
    //-------------------------------------------------------------------------

endmodule
