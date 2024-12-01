module miniALU_2 (
    // TODO: define your input and output ports
		input [3:0] op1,
		input [3:0] op2,
		input ope,
		input sign,
		output logic [7:0] displayBits [0:5]
    );
	 
	logic [19:0] res;
	displayEncoder DE (.result(res),.displayBits(displayBits));
    // The following block contains the logic of your combinational circuit
    always_comb begin
        if(ope==0) begin
				if(sign==0) begin
					res = op1+op2;
				end
				else begin
					res = op1-op2;
				end
			end
			else begin
				if(sign==0) begin
					res = op1 << op2;
				end
				else begin
					res = op1 >>> op2;
				end
			end
    end
endmodule