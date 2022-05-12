module MC_CORE(
    input         clk,
    input         rst_n, 
    input         start, 
    input  [11:0] path,  
    input  [11:0] K, 
    output        resend, // After regression, we need to traverse all path and calculate the expected profits.
    output        valid, 
    output [11:0] price, 
);

localparam DAY = 8;
localparam N = 256;
localparam IDLE        = 3'd0
localparam GET_PROFIT  = 3'd1;
localparam REGRESSION  = 3'd2;
localparam CALC_PROFIT = 3'd3;
localparam UPDATE_CF   = 3'd4;
localparam AVERAGE     = 3'd5;

reg [11:0] cf_mat_r[0:N-1];
reg [11:0] cf_mat_w[0:N-1];
reg [2:0] state_r, state_w;
reg [9:0] count_r, count_w;
reg [11:0] profit_r, profit_w;
reg [11:0] path_r, path_w;
reg [11:0] expected_profit_r, expected_profit_w;
wire XTX_valid, XTY_valid, INV_valid;
reg regression_start_r, regression_start_w; // start regression
reg [15:0] b0_r, b0_w, b1_r, b1_w; // Result of (XTX)^(-1)XTY
// calc average
reg [19:0] sum_r, sum_w;
wire [11:0] average;
integer i;
reg        valid_w, valid_r;
reg resend_r, resend_w;

// TODO:
// Add XTX, XTY, INV wires


assign valid = valid_r;
assign average = sum_r[19 -: 11]; // this should be modified when N change. sum_r[19 -: 19-log(2)N]
assign resend = resend_r;

always @(*) begin
    count_w = count_r;
    state_w = state_r;
    profit_w = profit_r;
    path_w = path_r;
    regression_start_w = regression_start_r;
    b0_w = b0_r;
    b1_w = b1_r;
    expected_profit_w = expected_profit_r;
    resend_w = resend_r;
    for (i=0; i<N; i=i+1) begin
        cf_mat_w[i] = cf_mat_r[i];
    end
    case (state_r):
        IDLE: begin
            if (start) state_w = GET_PROFIT;
            else state_w = IDLE;
        end

        GET_PROFIT: begin
            if (path > K) profit_w = path - K;
            else profit_w = 0;
            path_w = path;
            state_w = REGRESSION;
            regression_start_w = 1'b1;
        end
        
        REGRESSION: begin
            if (INV_valid) begin
                b0_w = INV_0 * XTY_0 + INV_1 * XTY_1;
                b1_w = INV_1 * XTY_0 + INV_2 * XTY_1;
                state_w = CALC_PROFIT;
                resend_w = 1'b1;
                count_w = 0;
            end
            else begin
                count_w = count_r + 1
                if (path > K) profit_w = path - K;
                else profit_w = 0;
                state_w = REGRESSION;
            end

        end

        CALC_PROFIT: begin
            state_w = UPDATE_CF;
            expected_profit_w = b0_r + b1_r * path;
            path_w = path;
        end
        
        UPDATE_CF: begin
            if (count_r == N-1) begin
                state_w = AVERAGE;
                count_w = 0;
                resend_w = 1'b0;
                if (expected_profit_r > (path_r - K) || (path_r - K) < 0) cf_mat_w[count_r] = cf_mat_r[count_r];
                else cf_mat_w[count_r] = (path_r - K);
            end
            else begin
                path_w = path;
                state_w = UPDATE_CF;
                count_w = count_r + 1;
                expected_profit_w = b0_r + b1_r * path;
                if (expected_profit_r > (path_r - K) || (path_r - K) < 0) cf_mat_w[count_r] = cf_mat_r[count_r];
                else cf_mat_w[count_r] = (path_r - K);
            end
        end

        AVERAGE: begin
            // TODO
            // Average every element of cf_mat to get the price
            // pull up valid
            
            if (count_r == N) begin
                state_w = IDLE;
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
        state_r <= IDLE;
        count_r <= 10'b0;
        profit_r <= 12'b0;
        path_r <= 12'b0;
        for (integer i = 0; i < N; i = i+1) begin
            cf_mat_r[i] <= 12'b0;
        end
        valid_r <= 1'b0;
        sum_r <= 20'b0;
        regression_start_r <= 1'b0;
        b0_r <= 0;
        b1_r <= 0;
        expected_profit_r <= 0;
        resend_r <= 1'b0;
    end
    else begin
        state_r <= state_w;
        count_r <= count_w;
        profit_r <= profit_w;
        path_r <= path_w;
        for (integer i = 0; i < N; i = i+1) begin
            cf_mat_r[i] <= cf_mat_w[i];
        end
        valid_r <= valid_w;
        sum_r <= sum_w;
        regression_start_r <= regression_start_w;
        b0_r <= b0_w;
        b1_r <= b1_w;
        expected_profit_r <= expected_profit_w;
        resend_r <= resend_w;
    end
end

XTX xtx0(
    .clk(clk),
    .rst_n(rst_n),
    .start(regression_start_r),
    .xi(path_r),
    .XTX_valid(XTX_valid), 
    .ans0(XTX_0),
    .ans1(XTX_1),
    .ans2(XTX_2),
);

XTY xty0(
    .clk(clk),
    .rst_n(rst_n), 
    .start(regression_start_r),
    .xi(path_r),
    .yi(cf_mat_r[count_r]),
    .XTY_valid(XTY_valid), 
    .out1(XTY_0),
    .out2(XTY_1),
);

MAT_INV inv0(
    .clk(clk),
    .rst_n(rst_n), 
    .start(start),
    .sig0(XTX_0),
    .sig1(XTX_1),
    .sig2(XTX_2),
    .out0(INV_0),
    .out1(INV_1),
    .out2(INV_2)
);


// TODO: consider if we need this module, or directly use matrix multiplications
// Regression regression0(
//     .clk(clk),
//     .rst_n(rst_n), 
//     .start(start), 
//     .xi(), 
//     .yi(), 
//     .valid(regression_valid), 
//     .expected_profit(expected_profit)
// );


endmodule