module sevenSegDigit(
	// TODO: define your input and output ports
	input [3:0] digit,
	output [7:0] displayBits
);

	// The following block contains the logic of your combinational circuit
	always_comb begin
		// TODO: fill out the case construct below to output the correct seven-segment display bits
		case (digit)
		  4'b0000: displayBits = 8'b11000000; // '0' 
        4'b0001: displayBits = 8'b11111001; // '1'
        4'b0010: displayBits = 8'b10100100; // '2'
        4'b0011: displayBits = 8'b10110000; // '3'
        4'b0100: displayBits = 8'b10011001; // '4'
        4'b0101: displayBits = 8'b10010010; // '5'
        4'b0110: displayBits = 8'b10000010; // '6'
        4'b0111: displayBits = 8'b11111000; // '7'
        4'b1000: displayBits = 8'b10000000; // '8'
        4'b1001: displayBits = 8'b10010000; // '9'
        default: displayBits = 8'b11111111; // Blank
			 // this is the "catch-all" case - if none of the above cases match, this will execute
				/* TODO: set your output bits */
		endcase
	end

endmodule
