// file: fft_top.sv
import fft_pkg::*;
module fft_top (
    input  logic clk, rst, start,
    input  logic signed [WIDTH-1:0] in  [3:0],
    output logic signed [WIDTH-1:0] out [3:0],
    output logic                    valid
);
    //import fft_pkg::*;

    typedef enum logic [1:0] {S_RESET, S_STAGE1, S_STAGE2, S_DONE} state_t;
    state_t state, next;

    logic signed [WIDTH-1:0] b0_s1, b1_s1, b2_s1, b3_s1;
    butterfly bf0 (.A(in [0]), .B(in [2]), .W(W0), .sum(b0_s1), .diff(b2_s1));
    butterfly bf1 (.A(in [1]), .B(in [3]), .W(W0), .sum(b1_s1), .diff(b3_s1));

    logic signed [WIDTH-1:0] b0_s2, b1_s2, b2_s2, b3_s2;
    butterfly bf2 (.A(b0_s1), .B(b1_s1), .W(W0), .sum(b0_s2), .diff(b2_s2));
    butterfly bf3 (.A(b2_s1), .B(b3_s1), .W(W1), .sum(b1_s2), .diff(b3_s2));

    always_ff @(posedge clk or posedge rst) begin
        if (rst) state <= S_RESET;
        else     state <= next;
    end

    always_comb begin
        next  = state;
        out   = '{default: 0};
        valid = 1'b0;

        unique case(state)
        S_RESET: if (start)               next = S_STAGE1;
        S_STAGE1:                         next = S_STAGE2;      // 1 cycle
        S_STAGE2:                         next = S_DONE;        // 1 cycle
        S_DONE:  begin
                     out[0]=b0_s2;
							out[1]=b1_s2;
							out[2]=b2_s2;
							out[3]=b3_s2;
                     valid = 1'b1;
                     if (rst)             next = S_RESET;
                 end
        endcase
    end
endmodule
