//module slotMachine_top();
`timescale 1ns/1ns

module slotMachine_top(input clk, output buzzer_out);

    //reg clk;
    reg rst;
    reg [19:0] speed;
    wire outClk;

    clock_divider #(.BASESPEED(50000000)) buzzer (
        .clk(clk),
        .speed(50000000),
        .rst(rst),
        .outClk(buzzer_out)
    );


endmodule