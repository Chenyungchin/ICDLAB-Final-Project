`timescale 1ns/10ps
`define CYCLE 10.0

module XTX_tb;

// clk generation
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// dump waveform
initial begin
    $fsdbDumpfile("Pricing.fsdb");
    $fsdbDumpvars(0, "+mda");
end

// time out
initial begin
    # (1000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end

// instantiate DUT
reg          rst_n = 1;
reg          start = 0;
// wire [31:0]  res0, res1, res2, res3;
// reg  [2:0]        inp;
// reg  [2:0]        inpy;
// reg  [4:0]        inp2;
// wire [12:0]  ans0;
// wire [12:0]  ans1;
// wire [12:0]  ans2;
// wire [12:0]  ans3;
// wire [12:0]  ans4;
reg [20:0] sig0;
reg [19:0] sig1;
reg [31:0] sig2;
wire [31:0] out0;
wire [19:0] out1;
wire [20:0] out2;
wire [5:0] location;
wire [15:0] test;
wire [15:0] det;
wire o_valid;
wire sign;

// XTX xtx0(
//     .clk(clk),
//     .rst_n(rst_n),
//     .start(start),
//     .xi(inp),
//     .ans0(ans0),
//     .ans1(ans1),
//     .ans2(ans2),
//     .ans3(ans3),
//     .ans4(ans4)
// );
// XTY xty0(
//     .clk(clk),
//     .rst_n(rst_n), 
//     .start(start),
//     .xi(inp),
//     .xi2(inp2),
//     .yi(inpy),
//     .out1(ans1),
//     .out2(ans2),
//     .out3(ans3)
    
// );
MAT_INV MI0(
    .clk(clk),
    .rst_n(rst_n), 
    .start(start),
    .sig0(sig0),
    .sig1(sig1),
    .sig2(sig2),
    .out0(out0),
    .out1(out1),
    .out2(out2),
    // .p(location),
    // .det(det),
    // .test(test),
    // .sign(sign),
    .o_valid(o_valid)
);

// input pattern
integer i;

initial begin
    // update weight
    
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
    //inp <=0;
    start = 1;
    sig0 = 9'b000000011;
    sig1 = 21'b000000000000001100000;
    sig2 = 33'b000000000000000000000111000000000;
    // sig0 = 9'b010110110;
    // sig1 = 21'b00010111001001001;
    // sig2 = 33'b0000010101101110101110111;
    $display("           Simulation Result      ");
    //$monitor("xi=%d ans0=%d ans1=%d ans2=%d ans3=%d ans4=%d\n",inp, ans0, ans1,ans2,ans3,ans4);
    //$monitor("inp=%d inpy=%d ans1=%d ans2=%d ans3=%d\n", inp, ans1,ans2,ans3);
    //$monitor("sig0=%d, sig1=%d, sig2=%d, out0=%b, ou1=%b, out2=%b, location=%d, x=%b, det=%b, valid=%d, sign=%d",sig0, sig1>>4, sig2>>8, out0, out1, out2, location, test, det, o_valid, sign);
    $monitor("sig0=%d, sig1=%d, sig2=%d, out0=%b, ou1=%b, out2=%b, valid=%d",sig0>>6, sig1>>6, sig2>>6, out0, out1, out2, o_valid);

    @(posedge clk);
end

endmodule