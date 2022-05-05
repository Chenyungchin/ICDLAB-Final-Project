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
// calc average
reg [19:0] sum_r, sum_w;
wire [11:0] average;
integer i;
reg        valid_w, valid_r;


assign valid = valid_r;
assign average = sum_r[19 -: 12];

always @(*) begin
    count_w = count_r;
    state_w = state_r;
    profit_w = profit_r;
    for (i=0; i<N; i=i+1) begin
        cf_mat_w[i] = cf_mat_r[i];
    end
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
            else state_w = REGRESSION;
        end
        
        UPDATE_CF: begin
            if (expected_profit > cf_mat_r[count_r]) cf_mat_w[count_r] = expected_profit;
            else cf_mat_w[count_r] = cf_mat_r[count_r];
            if (count_r == N-1) begin
                state_w = AVERAGE;
                count_w = 0;
            end
            else begin 
                state_w = UPDATE_CF;
                count_w = count_r + 1;
            end
        end

        AVERAGE: begin
            // TODO
            // Average every element of cf_mat to get the price
            // pull up valid
            
            if (count_r == N) begin
                state_w = GET_PROFIT;
                count_w = 0
                valid_w = 1'b1;
                sum_w = 0;
            end
            else begin 
                state_w = AVERAGE;
                count_w = count_r + 1;
                valid_w = 0;
                sum_w = sum_r + cf_mat_r[count_r];
            end
            // for (i=0; i<N; i=i+1) begin
            //     sum_w = sum_w + cf_mat_r[i];
            // end
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
        ave_r   <= 12'b0;
        valid_r <= 1'b0;
        sum_r <= 20'b0;
    end
    else begin
        state_r <= state_w;
        count_r <= count_w;
        profit_r <= profit_w;
        for (integer i = 0; i < N; i = i+1) begin
            cf_mat_r[i] <= cf_mat_w[i];
        end
        valid_r <= valid_w;
        sum_r <= sum_w;
    end
end

Regression regression0(
    .clk(clk),
    .rst_n(rst_n), 
    .profit(profit_r), 
    .valid(regression_valid), 
    .expected_profit(expected_profit)
);

endmodule