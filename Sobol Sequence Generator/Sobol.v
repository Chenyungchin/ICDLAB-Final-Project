module Sobol(
    input             clk,
    input             rst_n,
    input             start,
    output reg [15:0] res_fp16
);

// ========== wire and reg ===================
wire [31:0] res_int32;
wire [15:0] res_fp16_w;

// ========== Sequential =====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) res_fp16 <= 16'b0;
    else        res_fp16 <= res_fp16_w;
end


// ========== module instantiation ===========
Sobol_to_INT32 sobol_to_int32_0(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .res(res_int32)
);

INT32_to_FP16 int32_to_fp16_0(
    .int32_val(res_int32),
    .fp16_val(res_fp16_w)
);

endmodule