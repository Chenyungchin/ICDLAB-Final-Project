module XTX(
    input         clk,
    input         rst_n, 
    input         start,
    input  [11:0]  xi, 
    output [20:0] ans0,
    output [19:0] ans1,
    output [31:0] ans2,
    output [43:0] ans3,
    output [55:0] ans4
    // output reg [31:0] bx2,
    // output reg [31:0] bx3,
    // output reg [31:0] bx4
);
localparam n = 1024;


// ================== reg and wire ======================
reg [12:0] out0_r, out0_w;
reg [12:0] out1_r, out1_w;
reg [12:0] out2_r, out2_w;
reg [12:0] out3_r, out3_w;
reg [12:0] out4_r, out4_w;
// ================== wire assignments ==================
assign ans0 = out0_r;
assign ans1 = out1_r;
assign ans2 = out2_r;
assign ans3 = out3_r;
assign ans4 = out4_r;
// ================== Combinational =====================
always @(*) begin
    //inx_w = i*i;
    //counter_w = counter_r+1;
    //if(counter_r > 0) begin
    if(start == 1) begin
        out0_w = out0_r+1;
        out1_w = out1_r+(xi);
        out2_w = out2_r+(xi*xi); 
        out3_w = out3_r+(xi*xi*xi); 
        out4_w = out4_r+(xi*xi*xi*xi);  
     
    end    //end
end
// ================== Sequential ========================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out0_r <= 0;
        out1_r <= 0;
        out2_r <= 0;
        out3_r <= 0;
        out4_r <= 0;

    end
    else begin
        out0_r <= out0_w;
        out1_r <= out1_w;
        out2_r <= out2_w;
        out3_r <= out3_w;
        out4_r <= out4_w;
    end
end
endmodule

module XTY (
    input         clk,
    input         rst_n, 
    input         start,
    input  [15:0]  xi,
    input  [16:0]  xi2,
    input  [15:0]  yi,
    output [32:0]  out1,
    output [32:0]  out2,
    output [32:0]  out3

    
);
// ================== reg and wire ======================
reg [32:0] out1_r, out1_w;
reg [32:0] out2_r, out2_w;
reg [32:0] out3_r, out3_w;
integer i;
// ================== wire assignments ==================
assign out1 = out1_r;
assign out2 = out2_r;
assign out3 = out3_r;
// ================== Combinational =====================
always @(*) begin
    if(start == 1)begin
        out1_w = out1_r+yi;
        out2_w = out2_r+(xi*yi);
        out3_w = out3_r +(xi2*yi);
    end
end
// ================== Sequential ========================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out1_r <= 0;
        out2_r <= 0;
        out3_r <= 0;
    end
    else begin
        out1_r <= out1_w;
        out2_r <= out2_w;
        out3_r <= out3_w;        
    end
end

    
endmodule

module MAT_INV(
    input         clk,
    input         rst_n, 
    input         start,
    input [20:0] sig0,
    input [19:0] sig1,
    input [31:0] sig2,
    output [31:0] out0,
    output [19:0] out1,
    output [20:0] out2
);
// ================== reg and wire ======================
integer i;
localparam S_DET = 1'd0;
localparam S_INVMAT = 1'd1;
reg [52:0] det_r, det_w;
reg [2:0] counter_r,counter_w;
reg [5:0] location_r, location_w;
reg [52:0] x0_r, x0_w;
reg state_r, state_w;
reg ctrl_r, ctrl_w;
reg [20:0] sig0_r, sig0_w;
reg [19:0] sig1_r, sig1_w;
reg [31:0] sig2_r, sig2_w;
reg [31:0] out0_r, out0_w;
reg [19:0] out1_r, out1_w;
reg [20:0] out2_r, out2_w;
// ================== wire assignments ==================
assign out0 = out0_r;
assign out1 = out1_r;
assign out2 = out2_r;
// ================== Combinational =====================
always @(*) begin
    if(start == 1) begin
        location_w = location_r;
        x0_w = x0_r;
        sig0_w = sig0_r;
        sig1_w = sig1_r;
        sig2_w = sig2_r;
        ctrl_w = ctrl_r;
        case (state_r)
            S_DET: begin
                if(counter_r == 3'd0) begin
                    sig0_w = sig0;
                    sig1_w = sig1;
                    sig2_w = sig2;
                    det_w = (sig0 * sig2) - (sig1 * sig1);
                    state_w = S_DET;
                    counter_w = counter_r + 1;
                end
                else if(counter_r == 3'd1) begin
                    det_w = det_r;
                    state_w = S_DET;
                    counter_w = counter_r + 1;
                    x0_w = 53'd0;
                    for (i = 52; i >= 0; i=i-1) begin
                        if(ctrl_r == 0) begin
                            if (det_r[i] == 1) begin
                                location_w = i+1;
                                ctrl_w = 1;
                            end
                        end
                    end
                end
                else if(counter_r == 3'd2) begin
                    det_w = det_r;
                    state_w = S_DET;
                    x0_w[location_r+1] = 1'b1;
                    counter_w = counter_r + 1;
                end
                else if(counter_r > 3'd2 && counter_r < 3'd5) begin
                    counter_w = counter_r + 1;
                    x0_w = x0_r * (2-det_r*x0_r);
                    state_w = S_DET;
                end
                else begin
                    counter_w = 0;
                    state_w = S_INVMAT;
                end
            end
            S_INVMAT: begin
                out0_w = x0_r*sig2_r;
                out1_w = x0_r*sig1_r;
                out2_w = x0_r*sig0_r;
                state_w = S_INVMAT;
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
        location_r <= location_w;
        ctrl_r <= ctrl_w;
    end
end

endmodule