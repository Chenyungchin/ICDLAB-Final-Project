module ICDF_LUT(
    input               clk,
    input               rst_n,
    input       [31:0]  cdf,
    output reg  [15:0]  icdf
);
// =========== parameter ===============
parameter [16*64-1: 0] LUT = {
    16'ha103,
    16'ha785,
    16'haa45,
    16'hac64,
    16'hada6,
    16'haee8,
    16'hb016,
    16'hb0b8,
    16'hb15a,
    16'hb1fd,
    16'hb2a1,
    16'hb345,
    16'hb3ea,
    16'hb448,
    16'hb49b,
    16'hb4ef,
    16'hb543,
    16'hb598,
    16'hb5ee,
    16'hb644,
    16'hb69b,
    16'hb6f3,
    16'hb74c,
    16'hb7a5,
    16'hb7ff,
    16'hb82d,
    16'hb85c,
    16'hb88a,
    16'hb8ba,
    16'hb8ea,
    16'hb91b,
    16'hb94c,
    16'hb97f,
    16'hb9b2,
    16'hb9e6,
    16'hba1b,
    16'hba51,
    16'hba89,
    16'hbac1,
    16'hbafb,
    16'hbb37,
    16'hbb74,
    16'hbbb3,
    16'hbbf3,
    16'hbc1b,
    16'hbc3e,
    16'hbc61,
    16'hbc87,
    16'hbcae,
    16'hbcd6,
    16'hbd01,
    16'hbd2e,
    16'hbd5e,
    16'hbd91,
    16'hbdc8,
    16'hbe03,
    16'hbe44,
    16'hbe8d,
    16'hbede,
    16'hbf3d,
    16'hbfaf,
    16'hc021,
    16'hc088,
    16'hc152
};
// ================ wire and reg ==================
// whether cdf is greater than 0.5
wire GT05;
wire [5:0] index;
reg [16:0] icdf_w;
// ================ assignment ====================
assign GT05 = cdf[31];
assign index = cdf[30 -: 6];
// ================ Combinational =================
always@(*) begin
    if (!GT05) begin
        icdf_w = LUT[16*(index+1)-1 -: 16];    
    end
    else begin
        icdf_w = {1'b0, LUT[16*((63-index)+1)-2 -: 15]};
    end 
end
// ================ Sequential ====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) icdf <= 16'b0;
    else        icdf <= icdf_w;
end

endmodule