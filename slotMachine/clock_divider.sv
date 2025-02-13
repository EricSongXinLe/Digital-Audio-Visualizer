module clock_divider #(BASESPEED = 50000000)(
	input clk,
	input [19:0] speed,
	input rst,
	output logic outClk

	);

	logic [31:0] counter;
	logic [31:0] max_count;
	logic outClk_d;

	reg [1:0] rst_shift_reg;

	always_comb begin
		max_count = BASESPEED / speed - 1;
	end

	always @(posedge clk)begin
		rst_shift_reg <= {rst_shift_reg[0], rst};
		if (rst_shift_reg == 2'b10)begin
			outClk <= 0;
			counter <= 0;
		end
		else if (counter >= max_count)begin
			counter <= 0;
			outClk <= outClk_d;
		end else begin
			counter <= counter + 1;
			outClk <= outClk_d;
		end
	end

	always_comb begin
		if (rst_shift_reg == 2'b10)begin
			outClk_d = 0;
		end
		if (counter <= max_count / 2)begin
			outClk_d = 0;
		end
		else begin
			outClk_d = 1;
		end
end
endmodule