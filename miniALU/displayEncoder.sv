module displayEncoder(
	// TODO: define your input and output ports
	input [19:0] result,
	output logic [7:0] displayBits [0:5]
);
	// TODO: create signals for the six 4-bit digits
	
	// TODO: Instantiate six copies of sevenSegDigit, one for each digit (calculated below) 
	wire [3:0] digit0, digit1,digit2,digit3,digit4,digit5;
	// The following block contains the logic of your combinational circuit
	
	sevenSegDigit s0 (.digit(digit0),.displayBits(displayBits[0]));
	sevenSegDigit s1 (.digit(digit1),.displayBits(displayBits[1]));
	sevenSegDigit s2 (.digit(digit2),.displayBits(displayBits[2]));
	sevenSegDigit s3 (.digit(digit3),.displayBits(displayBits[3]));
	sevenSegDigit s4 (.digit(digit4),.displayBits(displayBits[4]));
	sevenSegDigit s5 (.digit(digit5),.displayBits(displayBits[5]));
	
	always_comb begin
		digit0 = result % 4'd10; //10 has 4 binary bits, and it's decimal.
		digit1 = (result / 4'd10) % 4'd10;
		digit2 = (result / 'd100) % 4'd10;
		digit3 = (result / 'd1000) % 4'd10;
		digit4 = (result / 'd10000) % 4'd10;
		digit5 = (result / 'd100000) % 4'd10;
	end

endmodule