`timescale 1ns/1ns // time units of 1ns with 1ns precision
module miniALU_tb
(
	output logic [19:0] res
);

logic [3:0] op1;
logic [3:0] op2;
logic ope;
logic sign;
 
miniALU_2 DUT(
.op1(op1),
.op2(op2),
.ope(ope),
.sign(sign),
.res(res)
);

initial begin
	op1 = 4'b0001;
	op2 = 4'b0001;
	ope = 1'b0;
	sign = 1'b0;
	#10;
	op1 = 4'b0010;
	op2 = 4'b0001;
	ope = 1'b0;
	sign = 1'b1;
	#10;
	op1 = 4'b0001;
	op2 = 4'b0010;
	ope = 1'b1;
	sign = 1'b0;
	#10;
	op1 = 4'b0101;
	op2 = 4'b0010;
	ope = 1'b1;
	sign = 1'b1;
	#10;
end

endmodule