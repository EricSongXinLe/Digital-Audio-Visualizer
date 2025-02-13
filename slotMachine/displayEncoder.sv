module displayEncoder(
	input [11:0] slot,
	output logic [7:0] displayBits [0:5]
);
//
	wire [3:0] digit0, digit1,digit2,digit3,digit4,digit5;
	// The following block contains the logic of your combinational circuit
	
	sevenSegDigit s0 (.digit(digit0),.displayBits(displayBits[0]));
	sevenSegDigit s1 (.digit(digit1),.displayBits(displayBits[1]));
	sevenSegDigit s2 (.digit(digit2),.displayBits(displayBits[2]));
	sevenSegDigit s3 (.digit(digit3),.displayBits(displayBits[3]));
	sevenSegDigit s4 (.digit(digit4),.displayBits(displayBits[4]));
	sevenSegDigit s5 (.digit(digit5),.displayBits(displayBits[5]));
	
	always_comb begin
		digit0 = slot[3:0] % 4'd10; 
		digit1 = slot[3:0] / 4'd10; //No need to mod 10 anymore
		digit2 = slot[7:4]  % 4'd10;
		digit3 = slot[7:4] / 4'd10;
		digit4 = slot[11:8]  % 4'd10;
		digit5 = slot[11:8] / 4'd10;
	end

endmodule