module Pricing(
    input         clk,
    input         rst_n, 
    input  [11:0] path, 
    input  [11:0] K, 
    output [11:0] price,
    output        valid);

localparam CORE_NUM = 4;

wire core_0_valid, core_1_valid, core_2_valid, core_3_valid;
wire [11:0] core_0_price, core_1_price, core_2_price, core_3_price;
reg [11:0] path_0, path_1, path_2, path_3;
reg [9:0] count_r, count_w;
reg [14:0] price_tmp;
reg valid_r, valid_w;
reg [11:0] price_r;

assign price = price_r;
assign valid = valid_r;

always @(*) begin
    count_w = count_r + 1;
    if (core_0_valid && core_1_valid && core_2_valid && core_3_valid) begin
        price_tmp = core_0_price + core_1_price + core_2_price + core_3_price;
        valid_w = 1;
    end
    else valid_w = 0;
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count_r <= 0;
        path_0 <= 0;
        path_1 <= 0;
        path_2 <= 0;
        path_3 <= 0;
        valid_r <= 0;
        price_r <= 0
    end
    else begin
        count_r <= count_w;
        valid_r <= valid_w;
        price_r <= price_tmp >> 2
        case (count_r[1:0]):
            2'b00: begin
                path_0 <= path;
                path_1 <= 0;
                path_2 <= 0;
                path_3 <= 0;
            end
            2'b01: begin
                path_0 <= 0;
                path_1 <= path;
                path_2 <= 0;
                path_3 <= 0;
            end
            2'b10: begin
                path_0 <= 0;
                path_1 <= 0;
                path_2 <= path;
                path_3 <= 0;
            end
            2'b11: begin
                path_0 <= 0;
                path_1 <= 0;
                path_2 <= 0;
                path_3 <= path;
            end
    end
end

MC_CORE mc_core0(
    .clk(clk),
    .rst_n(rst_n), 
    .start(), 
    .path(path_0),  
    .K(K), 
    .resend(), 
    .valid(core_0_valid), 
    .price(core_0_price)
);
MC_CORE mc_core1(
    .clk(clk),
    .rst_n(rst_n), 
    .start(), 
    .path(path_1),  
    .K(K), 
    .resend(), 
    .valid(core_1_valid), 
    .price(core_1_price)
);
MC_CORE mc_core2(
    .clk(clk),
    .rst_n(rst_n), 
    .start(), 
    .path(path_2),  
    .K(K), 
    .resend(), 
    .valid(core_2_valid), 
    .price(core_2_price)
);
MC_CORE mc_core3(
    .clk(clk),
    .rst_n(rst_n), 
    .start(), 
    .path(path_3),  
    .K(K), 
    .resend(), 
    .valid(core_3_valid), 
    .price(core_3_price)
);
endmodule