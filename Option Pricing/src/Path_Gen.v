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

reg [11:0] out0_r, out0_w;
reg [11:0] out1_r, out1_w;
reg [11:0] out2_r, out2_w;
reg [11:0] out3_r, out3_w;
reg day1;

assign path = out3_r;
assign valid = out3_r != 12'b0;

always @(*) begin
    // TODO: Change the multiplier to fp12 multiplier
    out0_w = w * epsilon;
    out1_w = out0_r * q;
    out2_w = day1? out1_r * S0 : out1_r * out2_r;
    day1 = (out2_r == 12'b0)? 1 : 0;

    // TODO: fp12 to int function for out3_w

end


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
endmodule