module Pricing(
    input         clk,
    input         rst_n, 
    input         start,
    input  [11:0] path, 
    input  [11:0] K, 
    output        resend,
    output [11:0] price,
    output        valid);

localparam CORE_NUM = 1;
localparam CYCLE = 8;
localparam S_IDLE = 2'd0;
localparam S_AVERAGE = 2'd1;

reg [1:0] state_r, state_w;
reg [3:0] cycle_r, cycle_w;
wire core_0_valid;
wire [11:0] core_0_price;
reg [9:0] count_r, count_w;
reg [14:0] price_sum_r, price_sum_w;
reg valid_r, valid_w;
reg [11:0] price_r;

assign price = price_sum_r[14 -: 12];
assign valid = valid_r;

always @(*) begin
    count_w = count_r + 1;
    valid_w = valid_r;
    price_sum_w = price_sum_r;
    state_w = state_r;
    cycle_w = cycle_r;
    case (state_r)
        S_IDLE: begin
            if (start) begin
                state_w = S_AVERAGE;
                cycle_w = 0;
            end
        end
        S_AVERAGE: begin
            if (core_0_valid) begin
                price_sum_w = core_0_price + price_sum_r;
                cycle_w = cycle_r + 1;
            end
            else begin
                price_sum_w = price_sum_r;
                valid_w = 0;
            end
            if (cycle_r == CYCLE) begin
                valid_w = 1;
                state_w = S_IDLE;
            end
        end
    endcase
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        count_r <= 0;
        valid_r <= 0;
        price_sum_r <= 0;
        state_r <= S_IDLE;
        cycle_r <= 0;
    end
    else begin
        count_r <= count_w;
        valid_r <= valid_w;
        price_sum_r <= price_sum_w;
        state_r <= state_w;
        cycle_r <= cycle_w;
    end
end

MC_CORE mc_core0(
    .clk(clk),
    .rst_n(rst_n), 
    .start(start), 
    .path(path),  
    .K(K), 
    .resend(resend), 
    .valid(core_0_valid), 
    .price(core_0_price)
);
endmodule