module MC_CORE(
    input         clk,
    input         rst_n, 
    input  [11:0] path,  
    input  [11:0] K, 
    output        valid, 
    output [11:0] price
);

localparam DAY = 8;
localparam N = 128;
localparam GET_PROFIT = 2'd0;
localparam REGRESSION = 2'd1;
localparam UPDATE_CF  = 2'd2;
localparam AVERAGE    = 2'd3;

reg [11:0] cf_mat_r[0:N-1];
reg [11:0] cf_mat_w[0:N-1];
reg [1:0] state_r, state_w;
reg [9:0] count_r, count_w;
reg [11:0] profit_r, profit_w;
wire [11:0] expected_profit;
wire regression_valid;

always @(*) begin
    count_w = count_r;
    state_w = state_r;
    profit_w = profit_r;
    cf_mat_w = cf_mat_r;
    case (state_r):
        GET_PROFIT: begin
            if (path > K) profit_w = path - K;
            else profit_w = 0;
            state_w = REGRESSION;
        end
        
        REGRESSION: begin
            if (path > K) profit_w = path - K;
            else profit_w = 0;
            if (regression_valid) state_w = UPDATE_CF;
        end
        
        UPDATE_CF: begin
            count_w = count_r + 1;
            if (expected_profit > cf_mat_r[count_r]) cf_mat_w[count_r] = expected_profit;
            else cf_mat_w[count_r] = cf_mat_r[count_r];
            if (count_r == N-1) state_w = AVERAGE;
        end

        AVERAGE: begin
            // TODO
            // Average every element of cf_mat to get the price
            // pull up valid
        end

    endcase

end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_r <= GET_PROFIT;
        count_r <= 10'b0;
        profit_r <= 12'b0;
        for (integer i = 0; i < N; i = i+1) begin
            cf_mat_r[i] <= 12'b0;
        end
    end
    else begin
        state_r <= state_w;
        count_r <= count_w;
        profit_r <= profit_w;
        for (integer i = 0; i < N; i = i+1) begin
            cf_mat_r[i] <= cf_mat_w[i];
        end
    end
end

// TODO: consider if we need this module, or directly use matrix multiplications
Regression regression0(
    .clk(clk),
    .rst_n(rst_n), 
    .profit(profit_r), 
    .valid(regression_valid), 
    .expected_profit(expected_profit)
);

endmodule