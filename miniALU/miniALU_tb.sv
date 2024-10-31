`timescale 1ns/1ns // time units of 1ns with 1ns precision
module miniALU_tb
(
	output logic [9:0] leds
);

logic [9:0] inputArr;
 
miniALU_top DUT(
.in(inputArr),
.out(leds)
);

initial begin
	inputArr = 10'b0000000000;
	#10;
	inputArr = 10'b1111111111;
	#10;
end

endmodule