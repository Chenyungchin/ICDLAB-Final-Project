module CHIP(
    input         clk,
    input         rst_n, 
    input  [1:0]  state, // 0: IDLE, 1: parameter mode 2: sobol mode, 3: pricing mode
    input  [11:0] in, 
    output        valid, 
    output [11:0] out, 
    output        resend // In the pricing mode, when resend, send the path again
);

localparam DAY = 8;
localparam N = 256;
localparam S_IDLE = 3'd0;
localparam S_PARAM = 3'd1; // w -> q -> S -> K
localparam S_SOBOL = 3'd2;
localparam S_ICDF = 3'd3;
localparam S_PRICING = 3'd4;
localparam S_OUT = 3'd5;

// ========== wire and reg ====================
// Sobol
wire  [12:0] icdf;
wire  sobol_start, gen_start, pricing_start;
reg   sobol_start_r, sobol_start_w;
reg   gen_start_r, gen_start_w;
reg   pricing_start_r, pricing_start_w;
wire  [11:0] w, q, S, K;
reg   [11:0] w_r, w_w, q_r, q_w, S_r, S_w, K_r, K_w;
wire  [11:0] path, price, pricing_path;
// wire  resend;
wire  gen_valid, pricing_valid;
reg   [2:0] state_r, state_w;
reg   [12:0] count_r, count_w;
reg   [4:0] count_day_r, count_day_w;

assign sobol_start = sobol_start_r;
assign gen_start = gen_start_r;
assign pricing_start = pricing_start_r;
assign w = w_r;
assign q = q_r;
assign S = S_r;
assign K = K_r;
assign valid = gen_valid || pricing_valid;
assign out = (gen_valid)? path : (pricing_valid)? price : 12'bx;
assign pricing_path = in;
// ========== Combinational ===================
always @(*) begin
    sobol_start_w = sobol_start_r;
    gen_start_w = gen_start_r;
    pricing_start_w = pricing_start_r;
    w_w = w_r;
    q_w = q_r;
    S_w = S_r;
    K_w = K_r;
    state_w = state_r;
    count_w = count_r;
    count_day_w = count_day_r;
    case (state_r)
        S_IDLE: begin
            if (state == 2'b1) begin
                state_w = S_PARAM;
            end
            else begin
                state_w = S_IDLE;
            end
        end
        S_PARAM: begin
            if (state == 2'd2) begin
                state_w = S_SOBOL;
                count_w = 13'b0;
            end
            else begin
                state_w = S_PARAM;
                case (count_r) 
                    13'd0: w_w = in;
                    13'd1: q_w = in;
                    13'd2: S_w = in;
                    13'd3: K_w = in;
                endcase
                count_w = count_r + 1;
            end
        end
        S_SOBOL: begin
            sobol_start_w = 1'b1;
            if (count_r < 2000) begin
                count_w = count_r + 1;
                state_w = S_SOBOL;
            end
            else begin
                count_w = 13'b0;
                state_w = S_ICDF;
                gen_start_w = 1'b1;
            end
        end
        S_ICDF: begin
            if (state == 2'd3) begin
                state_w = S_PRICING;
                count_w = 0;
                pricing_start_w = 1'b1;
                gen_start_w = 1'b0;
            end
            else if (count_day_r < (DAY - 1) && gen_valid) begin
                count_day_w = count_day_r + 1;
                state_w = S_ICDF;
            end
            else if (count_day_r == (DAY - 1)) begin // The 8th cycle of path generating
                count_day_w = 5'b0;
                if (count_r < (N - 1)) begin
                    count_w = count_r + 1;
                end
                else begin
                    count_w = 0;
                end
                state_w = S_ICDF;
            end
            else begin
                state_w = S_ICDF;
            end
        end
        S_PRICING: begin
            if (pricing_valid) begin
                state_w = S_OUT;
            end
            else state_w = S_PRICING;
        end
        S_OUT: begin
            if (state == 2'd0) begin
                state_w = S_IDLE;
            end
            else state_w = S_OUT;
        end
    endcase
end

// ========== Sequential ======================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sobol_start_r <= 1'b0;
        gen_start_r <= 1'b0;
        pricing_start_r <= 1'b0;
        w_r <= 12'b0;
        q_r <= 12'b0;
        S_r <= 12'b0;
        K_r <= 12'b0;
        state_r <= S_IDLE;
        count_r <= 13'b0;
        count_day_r <= 5'b0;
    end
    else begin
        sobol_start_r <= sobol_start_w;
        gen_start_r <= gen_start_w;
        pricing_start_r <= pricing_start_w;
        w_r <= w_w;
        q_r <= q_w;
        S_r <= S_w;
        K_r <= K_w;
        state_r <= state_w;
        count_r <= count_w;
        count_day_r <= count_day_w;
    end
end

// ========== Module Instantiation ============
Sobol sobol0(
    .clk(clk),
    .rst_n(rst_n),
    .start(sobol_start),
    .icdf(icdf)
);

Path_Gen path_gen0(
    // input
    .clk(clk),
    .rst_n(rst_n),
    .start(gen_start),
    .w(w),
    .q(q),
    .epsilon(icdf),
    .S0(S),
    // output
    .valid(gen_valid),
    .path(path)
);

Pricing pricing0(
    .clk(clk),
    .rst_n(rst_n),
    .start(pricing_start),
    .path(pricing_path), 
    .K(K), 
    .resend(resend), 
    .price(price),
    .valid(pricing_valid)
);
endmodule