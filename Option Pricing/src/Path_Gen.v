module Path_Gen(
    input         clk,
    input         rst_n, 
    input  [11:0] w, 
    input  [11:0] q, 
    input  [11:0] epsilon, 
    input  [11:0] S0, 
    output        valid, 
    output [11:0] path
);

reg [11:0] out0_r;
reg [11:0] out1_r;
reg [11:0] out2_r;
reg [11:0] out3_r;

wire [11:0] out0_w, out1_w, out2_w, out3_w;
reg day1;

assign path = out3_r;
assign valid = out3_r != 12'b0;

// always @(*) begin
//     // TODO: Change the multiplier to fp12 multiplier
//     // out0_w = w * epsilon;
//     // out1_w = out0_r * q;
//     // out2_w = out1_r * (day1 ? S0 : out2_r);
//     // day1 = (out2_r == 12'b0)? 1 : 0;

//     // TODO: fp12 to int function for out3_w

// end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out0_r <= 12'b0;
        out1_r <= 12'b0;
        out2_r <= 12'b0;
        out3_r <= 12'b0;
    end
    else begin
        out0_r <= out0_w;
        out1_r <= out1_w;
        out2_r <= out2_w;
        out3_r <= out3_w;
    end
end

// ========== module instantiation ==============
// out0_w = w x epsilon
FP12_MULT #( 
    .IN1_POINT(8),
    .IN2_POINT(8),
    .OUT_POINT(8),
    .IN1_BIAS (7),
    .IN2_BIAS (7),
    .OUT_BIAS (7)
) fp12_mult_w_x_epsilon(
    .in1(w),
    .in2(epsilon),
    .out(out0_w)
);
// out1_w = out0_r x q
FP12_MULT #( 
    .IN1_POINT(8),
    .IN2_POINT(8),
    .OUT_POINT(8),
    .IN1_BIAS (7),
    .IN2_BIAS (7),
    .OUT_BIAS (7)
) fp12_mult_out0_r_x_q(
    .in1(out0_r),
    .in2(q),
    .out(out1_w)
);
// out2_w = out1_r * (day1 ? S0 : out2_r)
FP12_MULT #( 
    .IN1_POINT(8),
    .IN2_POINT(8),
    .OUT_POINT(8),
    .IN1_BIAS (7),
    .IN2_BIAS (7),
    .OUT_BIAS (7)
) fp12_mult_out1_r_x_mux(
    .in1(out1_r),
    .in2(day1 ? S0 : out2_r),
    .out(out2_w)
);

endmodule