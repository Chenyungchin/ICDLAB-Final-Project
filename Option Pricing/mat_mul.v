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
assign out1 = out1_r
assign out2 = out2_r
assign out3 = out3_r
// ================== Combinational =====================
always @(*) begin
    if(start == 1)begin
        out1_w = out1_r+yi;
        out2_w = out2_r+(xi*yi);
        out3_w = out3-R +(xi2*yi);
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

);