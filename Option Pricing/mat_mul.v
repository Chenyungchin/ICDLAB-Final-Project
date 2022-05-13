module XTX(
    input         clk,
    input         rst_n, 
    input         start,
    input  [11:0] xi, //8, 4
    output        XTX_valid, 
    output [20:0] ans0,
    output [19:0] ans1,
    output [31:0] ans2
    // output [43:0] ans3,
    // output [55:0] ans4
    // output reg [31:0] bx2,
    // output reg [31:0] bx3,
    // output reg [31:0] bx4
);
localparam N = 256;
localparam IDLE = 2'd0;
localparam IN = 2'd1;
localparam OUT = 2'd2;

// ================== reg and wire ======================
reg [12:0] out0_r, out0_w;
reg [12:0] out1_r, out1_w;
reg [12:0] out2_r, out2_w;
reg [9:0]  count_r, count_w;
reg [1:0]  state_r, state_w;
reg        valid_r, valid_w;
// reg [12:0] out3_r, out3_w;
// reg [12:0] out4_r, out4_w;
// ================== wire assignments ==================
assign ans0 = out0_r;
assign ans1 = out1_r;
assign ans2 = out2_r;
assign XTX_valid = valid_r;
// assign ans3 = out3_r;
// assign ans4 = out4_r;
// ================== Combinational =====================
always @(*) begin
    //inx_w = i*i;
    //counter_w = counter_r+1;
    //if(counter_r > 0) begin
    out0_w = out0_r;
    out1_w = out1_r;
    out2_w = out2_r;
    state_w = state_r;
    count_w = count_r;
    valid_w = valid_r;
    case (state_r)
        IDLE: begin
            if (start) begin
                state_w = IN;
            end
        end

        IN: begin
            valid_w = 1'b0;
            if (count_r == N) begin
                state_w = OUT;
            end
            else begin
                out0_w = out0_r + 1;
                out1_w = out1_r + xi;
                out2_w = out2_r + (xi * xi);
                count_w = count_r + 1'b1;
                // out3_w = out3_r+(xi*xi*xi); 
                // out4_w = out4_r+(xi*xi*xi*xi);  
            end
        end

        OUT: begin
            valid_w = 1'b1;
            state_w = IDLE;
        end
    endcase
end
// ================== Sequential ========================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out0_r <= 0;
        out1_r <= 0;
        out2_r <= 0;
        count_r <= 0;
        state_r <= IDLE;
        valid_r <= 1'b0;
        // out3_r <= 0;
        // out4_r <= 0;

    end
    else begin
        out0_r <= out0_w;
        out1_r <= out1_w;
        out2_r <= out2_w;
        count_r <= count_w;
        state_r <= state_w;
        valid_r <= valid_w;
        // out3_r <= out3_w;
        // out4_r <= out4_w;
    end
end
endmodule

module XTY (
    input         clk,
    input         rst_n, 
    input         start,
    input  [15:0]  xi,
    // input  [16:0]  xi2,
    input  [15:0]  yi,
    output         XTY_valid, 
    output [32:0]  out1,
    output [32:0]  out2
    // output [32:0]  out3
);

localparam N = 256;
localparam IDLE = 2'd0;
localparam IN = 2'd1;
localparam OUT = 2'd2;

// ================== reg and wire ======================
reg [32:0] out1_r, out1_w;
reg [32:0] out2_r, out2_w;
reg [9:0]  count_r, count_w;
reg [1:0]  state_r, state_w;
reg        valid_r, valid_w;
// reg [32:0] out3_r, out3_w;
// integer i;
// ================== wire assignments ==================
assign out1 = out1_r;
assign out2 = out2_r;
assign XTY_valid = valid_r;
// assign out3 = out3_r;
// ================== Combinational =====================
always @(*) begin
    out1_w = out1_r;
    out2_w = out2_r;
    count_w = count_r;
    state_w = state_r;
    valid_w = valid_r;
    case (state_r)
        IDLE: begin
            if (start) begin
                state_w = IN;
            end
        end

        IN: begin
            valid_w = 1'b0;
            if (count_r == N) begin
                state_w = OUT;
            end
            else begin
                out1_w = out1_r + yi;
                out2_w = out2_r + (xi * yi);
                count_w = count_r + 1'b1;
                // out3_w = out3_r +(xi2*yi);
            end
        end

        OUT: begin
            valid_w = 1'b1;
            state_w = IDLE;
        end
    endcase
end
// ================== Sequential ========================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out1_r <= 0;
        out2_r <= 0;
        count_r <= 0;
        state_r <= IDLE;
        valid_r <= 1'b0;
        // out3_r <= 0;
    end
    else begin
        out1_r <= out1_w;
        out2_r <= out2_w;
        count_r <= count_w;
        state_r <= state_w;
        valid_r <= valid_w;
        // out3_r <= out3_w;        
    end
end

    
endmodule
//sign+integer, fraction
module MAT_INV(
    input         clk,
    input         rst_n, 
    input         start,
    input [8:0] sig0, //9, 0
    input [20:0] sig1,//17, 4
    input [32:0] sig2,//25, 8 
    output signed[31:0] out0,//22, 10
    output signed[19:0] out1,//12, 8
    output signed[20:0] out2,//15, 6
    // output [5:0] p,
    // output signed [15:0] det,
    // output signed[15:0] test,
    output o_valid
    //output sign
);
// ================== reg and wire ======================
integer i;
localparam S_DET = 1'd0;
localparam S_INVMAT = 1'd1;
reg signed [41:0] det_r, det_w; //34 ,8
wire signed [15:0] det_f; //10, 6
reg [2:0] counter_r,counter_w;
reg [5:0] location_r, location_w;
reg signed[15:0] x0_r, x0_w; //10, 6
reg state_r, state_w;
reg ctrl_r, ctrl_w;
reg [8:0] sig0_r, sig0_w; //9, 0
reg [20:0] sig1_r, sig1_w; //17, 4
reg [32:0] sig2_r, sig2_w; //25, 8
reg signed[48:0] out0_r, out0_w; //22, 10  //35,14
reg signed[36:0] out1_r, out1_w; //12, 8   //27,10
reg signed[24:0] out2_r, out2_w; //15, 6   //19,6
reg [31:0] temp1_w, temp1_r;
reg [47:0] temp2_w, temp2_r;
reg valid_w, valid_r;
reg sign_w, sign_r;
// ================== wire assignments ==================
assign out0 = out0_r[35:4];
assign out1 = out1_r[21:2];
assign out2 = out2_r[20:0];
// assign test = x0_r;
// assign p = location_r;
assign det_f = det_r[17:2];
// assign det = det_r[17:2];
assign o_valid = valid_r;
// assign sign = sign_r;
// ================== Combinational =====================
always @(*) begin
    if(start == 1) begin
        location_w = location_r;
        x0_w = x0_r;
        sig0_w = sig0_r;
        sig1_w = sig1_r;
        sig2_w = sig2_r;
        ctrl_w = ctrl_r;
        sign_w = sign_r;
        case (state_r)
            S_DET: begin
                if(counter_r == 4'd0) begin
                    sig0_w = sig0;
                    sig1_w = sig1;
                    sig2_w = sig2;
                    det_w = (sig0 * sig2) - (sig1 * sig1);
                    state_w = S_DET;
                    counter_w = counter_r + 1;
                end
                else if(counter_r == 4'd1) begin
                    det_w = det_r;
                    state_w = S_DET;
                    x0_w = 16'd1;
                    for (i = 40; i >= 10; i=i-1) begin
                        if(ctrl_r == 0) begin
                            if(det_r[41] == 1) begin
                                det_w = ~det_r +1'b1;
                                sign_w = 1;
                                counter_w = counter_r;
                            end
                            else if (det_r[i] == 1) begin
                                location_w = i-7;
                                ctrl_w = 1;
                                counter_w = counter_r + 1;
                            end
                        end
                    end
                end
                else if(counter_r == 4'd2) begin
                    det_w = det_r;
                    state_w = S_DET;
                    counter_w = counter_r + 1;
                    x0_w = (16'b0000000010000000 << location_r) - det_f;
                end
                else if(counter_r == 4'd3) begin
                    counter_w = counter_r + 1;
                    temp1_w = (16'b0000000010000000 << location_r)*x0_r;
                    temp2_w = (det_f*(x0_r*x0_r) >> location_r);
                    x0_w = x0_r;
                end
                else if(counter_r == 4'd4) begin
                    counter_w = counter_r + 1;
                    x0_w = temp1_r[21:6] - temp2_r[27:12];
                end
                else begin
                    counter_w = 0;
                    x0_w = x0_r >> (location_r * location_r);
                    state_w = S_INVMAT;
                end
            end
            S_INVMAT: begin
                state_w = S_INVMAT;
                valid_w = 1;
                if(sign_r == 0) begin
                    out0_w = x0_r*sig2_r;
                    out1_w = x0_r*(~sig1_r+1'b1);
                    out2_w = x0_r*sig0_r; 
                end
                else begin
                    out0_w = x0_r*(~sig2_r+1'b1);
                    out1_w = x0_r*sig1_r;
                    out2_w = x0_r*(~sig0_r+1'b1); 
                end
            end 
        endcase
    end
end
// ================== Sequential ========================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        det_r <= 0;
        counter_r <= 0;
        state_r <= S_DET;
        sig0_r <= 0;
        sig1_r <= 0;
        sig2_r <= 0;
        out0_r <= 0;
        out1_r <= 0;
        out2_r <= 0;
        x0_r <= 0;
        location_r <= 0;
        ctrl_r <= 0;
        temp1_r <= 0;
        temp2_r <= 0;
        valid_r <= 0;
        sign_r <= 0;
    end
    else begin
        det_r <= det_w;
        counter_r <= counter_w;
        state_r <= state_w;
        sig0_r <= sig0_w;
        sig1_r <= sig1_w;
        sig2_r <= sig2_w;
        out0_r <= out0_w;
        out1_r <= out1_w;
        out2_r <= out2_w;
        x0_r <= x0_w;
        temp1_r <= temp1_w;
        temp2_r <= temp2_w;
        location_r <= location_w;
        ctrl_r <= ctrl_w;
        valid_r <= valid_w;
        sign_r <= sign_w;
    end
end

endmodule