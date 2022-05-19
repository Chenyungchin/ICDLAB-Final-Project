module Path_Gen(
    input         clk,
    input         rst_n, 
    input  [11:0] w, 
    input  [11:0] q, 
    input  [12:0] epsilon, 
    input  [11:0] S0, 
    output        valid, 
    output [11:0] path
);

reg [11:0] out0_r;
reg [11:0] out1_r;
reg [11:0] out2_r;
reg [11:0] out3_r;

wire [11:0] out0_w, out2_w, out3_w;
reg [11:0] out1_w;
wire        day1;

wire        epsilon_is_neg_ns;
reg         epsilon_is_neg;

assign path = out3_r;
assign valid = out3_r != 12'b0;
assign day1 = (out2_r == 12'b0) ? 1 : 0;
// sign bit of epsilon
assign epsilon_is_neg_ns = epsilon[12];

// ============ Combinational ====================
always @(*) begin
    if (epsilon_is_neg) out1_w = q - out0_r;
    else                out1_w = q + out0_r;
end


// ============ Sequential =======================
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
// epsilon sign
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) epsilon_is_neg <= 1'b0;
    else        epsilon_is_neg <= epsilon_is_neg_ns;
end

// ========== module instantiation ==============
// out0_w = w x epsilon
FP12_MULT #( 
    .INT_LEN(8)
) fp12_mult_w_x_epsilon(
    .in1(w),
    .in2(epsilon[11:0]),
    .out(out0_w)
);

// out2_w = out1_r * (day1 ? S0 : out2_r)
FP12_MULT #( 
    .INT_LEN(8)
) fp12_mult_out1_r_x_mux(
    .in1(out1_r),
    .in2(day1 ? S0 : out2_r),
    .out(out2_w)
);

endmodule