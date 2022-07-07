module Sobol(
    input             clk,
    input             rst_n,
    input             start,
    output     [15:0] icdf
);

// ========== wire and reg ===================
wire [31:0] res_int32;

// ========== Sequential =====================

// ========== module instantiation ===========
Sobol_to_INT32 sobol_to_int32_0(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .res(res_int32)
);

ICDF_LUT icdf_lut0(
    .clk(clk),
    .rst_n(rst_n),
    .cdf(res_int32),
    .icdf(icdf)
);

endmodule