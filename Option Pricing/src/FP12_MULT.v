// function: multiplication of unsigned 12 bit fixed point, output is also 12 bit fixed point
// the higher 8 bits represent the integer part, the lower 4 bits represent the decimal part
// ex: 00000011_1000 = 3.5
module FP12_MULT #(
    parameter INT_LEN = 8
)(
    input  [11:0] in1, 
    input  [11:0] in2,
    output [11:0] out
);

// =========== parameter ==============
parameter N           = 12;
parameter FIXED_POINT = (N - INT_LEN) * 2;
// =========== wire and reg ===========
wire  [23:0] out_tmp; 
wire   [7:0] out_int;
wire   [3:0] out_dec;
// =========== assignments ============
assign out_tmp = in1 * in2;
assign out = {out_int, out_dec};
assign out_int = out_tmp[FIXED_POINT+7: FIXED_POINT];
assign out_dec = out_tmp[FIXED_POINT-1 -: 4];

endmodule












// // IN1_POINT, IN2_POINT, OUT_POINT define the starting bit of exponent
// // ex: if POINT = 8, then exponent: [11:8], mantissa: [7:0]
// // no sign bit for fp12 since every component is positive

// module FP12_MULT #(
//     parameter IN1_POINT = 8,
//     parameter IN2_POINT = 8,
//     parameter OUT_POINT = 8,
//     parameter IN1_BIAS  = 7,
//     parameter IN2_BIAS  = 7,
//     parameter OUT_BIAS  = 7
// )(
//     input  [11:0] in1, 
//     input  [11:0] in2, 
//     output [11:0] out
// );

// // ======== parameter =========
// parameter N = 12;

// // ======== wire and reg ======
// wire [N-IN1_POINT-1: 0] in1_exp_biased;
// wire [N-IN2_POINT-1: 0] in2_exp_biased;
// wire [N-OUT_POINT-1: 0] out_exp_biased;

// wire [N-IN1_POINT-1: 0] in1_exponent;
// wire [N-IN2_POINT-1: 0] in2_exponent;
// reg  [N-OUT_POINT-1: 0] out_exponent;
// wire [N-OUT_POINT-1: 0] out_exponent_unshifted;

// wire [IN1_POINT-1: 0] in1_mantissa;
// wire [IN2_POINT-1: 0] in2_mantissa;
// reg  [OUT_POINT-1: 0] out_mantissa;
// wire [(IN1_POINT+1)+(IN2_POINT+1)-1:0] out_mantissa_unshifted;

// wire [IN1_POINT: 0] in1_mantissa_pad1;
// wire [IN2_POINT: 0] in2_mantissa_pad1;

// // ======== assignment ========
// assign in1_exp_biased = in1[N-1: IN1_POINT];
// assign in2_exp_biased = in2[N-1: IN1_POINT];
// // handle the bias of the exponents
// assign in1_exponent = in1_exp_biased - IN1_BIAS;
// assign in2_exponent = in2_exp_biased - IN2_BIAS;
// assign out_exp_biased = out_exponent + OUT_BIAS;

// assign in1_mantissa = in1[IN1_POINT-1: 0];
// assign in2_mantissa = in2[IN2_POINT-1: 0];
// // pad the 1 for the mantissas
// assign in1_mantissa_pad1 = {1'b1, in1_mantissa};
// assign in2_mantissa_pad1 = {1'b1, in2_mantissa};

// assign out = {out_exp_biased, out_mantissa};
// // add exponents of in1 and in2
// assign out_exponent_unshifted = in1_exponent + in2_exponent;
// // multiply mantissas of in1 and in2
// assign out_mantissa_unshifted = in1_mantissa_pad1 * in2_mantissa_pad1;

// // ========== Combinational =============
// always @(*) begin
//     // if carry, shift it
//     if (out_mantissa_unshifted[(IN1_POINT+1)+(IN2_POINT+1)-1] == 1'b1) begin
//         out_exponent = out_exponent_unshifted + 1;
//         out_mantissa = out_mantissa_unshifted[IN1_POINT+IN2_POINT -: OUT_POINT];
//     end
//     else begin
//         out_exponent = out_exponent_unshifted;
//         out_mantissa = out_mantissa_unshifted[IN1_POINT+IN2_POINT-1 -: OUT_POINT];
//     end
// end

// endmodule