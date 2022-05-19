module ICDF_LUT(
    input               clk,
    input               rst_n,
    input       [31:0]  cdf,
    output reg  [12:0]  icdf
);
// =========== parameter ===============
parameter [13*64-1: 0] LUT = {
    13'h1000,
    13'h1000,
    13'h1000,
    13'h1001,
    13'h1001,
    13'h1001,
    13'h1002,
    13'h1002,
    13'h1002,
    13'h1002,
    13'h1003,
    13'h1003,
    13'h1003,
    13'h1004,
    13'h1004,
    13'h1004,
    13'h1005,
    13'h1005,
    13'h1005,
    13'h1006,
    13'h1006,
    13'h1006,
    13'h1007,
    13'h1007,
    13'h1007,
    13'h1008,
    13'h1008,
    13'h1009,
    13'h1009,
    13'h1009,
    13'h100a,
    13'h100a,
    13'h100a,
    13'h100b,
    13'h100b,
    13'h100c,
    13'h100c,
    13'h100d,
    13'h100d,
    13'h100d,
    13'h100e,
    13'h100e,
    13'h100f,
    13'h100f,
    13'h1010,
    13'h1010,
    13'h1011,
    13'h1012,
    13'h1012,
    13'h1013,
    13'h1014,
    13'h1014,
    13'h1015,
    13'h1016,
    13'h1017,
    13'h1018,
    13'h1019,
    13'h101a,
    13'h101b,
    13'h101c,
    13'h101e,
    13'h1021,
    13'h1024,
    13'h102a
};
// ================ wire and reg ==================
// whether cdf is greater than 0.5
wire GT05;
wire [5:0] index;
reg [13:0] icdf_w;
// ================ assignment ====================
assign GT05 = cdf[31];
assign index = cdf[30 -: 6];
// ================ Combinational =================
always@(*) begin
    if (!GT05) begin
        icdf_w = LUT[13*(index+1)-1 -: 13];    
    end
    else begin
        icdf_w = {1'b0, LUT[13*((63-index)+1)-2 -: 12]};
    end 
end
// ================ Sequential ====================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) icdf <= 13'b0;
    else        icdf <= icdf_w;
end

endmodule