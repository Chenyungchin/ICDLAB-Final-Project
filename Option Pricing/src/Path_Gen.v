module Path_Gen(
    input         clk,
    input         rst_n, 
    input         start,
    input  [11:0] w, 
    input  [11:0] q, 
    input  [12:0] epsilon, 
    input  [11:0] S0, 
    output reg    valid, 
    output [11:0] path
);
// ================ parameters ================
parameter NUM_OF_DAYS = 8;
// parameter BUFFS_FOR_INPUT = 1;

parameter IDLE = 2'b00;
parameter BUFF = 2'b01; // for the 2 stage pipeline
parameter COMP = 2'b10;

// ================ reg and wire ==============
reg  [1:0] state, state_next;
reg  [2:0] day_curr, day_next;


reg [11:0] out0_r;
reg [11:0] out1_r;
reg [11:0] out2_r;

wire [11:0] out0_w, out2_w;
reg  [11:0] out1_w;

wire        day1;

wire        epsilon_is_neg_ns;
reg         epsilon_is_neg;

wire        valid_w;

// ================ assignments ===============

assign path = out2_r;
assign day1 = (state == COMP && day_curr == 3'b0) ? 1 : 0;
// sign bit of epsilon
assign epsilon_is_neg_ns = epsilon[12];

// valid
assign valid_w = (state == COMP);

// ============ Combinational ====================
// FSM
always @(*) begin
    state_next        = state;
    day_next          = day_curr;
    case (state)
        IDLE: begin
            if (start) state_next = BUFF;
            else       state_next = state;
        end
        BUFF: begin
            state_next = COMP;
        end
        COMP: begin
            if (day_curr == NUM_OF_DAYS-1) begin
                day_next   = 3'b0;
                state_next = IDLE; 
            end
            else begin
                day_next   = day_curr + 1;
                state_next = state;
            end
        end
        default: begin

        end
    endcase
end
// out1
always @(*) begin
    if (epsilon_is_neg) out1_w = q - out0_r;
    else                out1_w = q + out0_r;
end


// ============ Sequential =======================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out0_r   <= 12'b0;
        out1_r   <= 12'b0;
        out2_r   <= 12'b0;
        state    <= IDLE;
        day_curr <= 3'b0;
    end
    else begin
        out0_r   <= out0_w;
        out1_r   <= out1_w;
        out2_r   <= out2_w;
        state    <= state_next;
        day_curr <= day_next;
    end
end
// epsilon sign
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) epsilon_is_neg <= 1'b0;
    else        epsilon_is_neg <= epsilon_is_neg_ns;
end
// valid
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) valid   <= 1'b0;
    else        valid   <= valid_w;
end

// ========== module instantiation ==============
// out0_w = w x epsilon
FP12_MULT fp12_mult_w_x_epsilon(
    .in1(w),
    .in2(epsilon[11:0]),
    .out(out0_w)
);

// out2_w = out1_r * (day1 ? S0 : out2_r)
FP12_MULT fp12_mult_out1_r_x_mux(
    .in1(out1_r),
    .in2(day1 ? S0 : out2_r),
    .out(out2_w)
);

endmodule