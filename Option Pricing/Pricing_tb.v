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
wire [31:0]  res0, res1, res2, res3;
reg  [2:0]        inp;
reg  [2:0]        inpy;
reg  [4:0]        inp2;
wire [12:0]  ans0;
wire [12:0]  ans1;
wire [12:0]  ans2;
wire [12:0]  ans3;
wire [12:0]  ans4;

XTX xtx0(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .xi(inp),
    .ans0(ans0),
    .ans1(ans1),
    .ans2(ans2),
    .ans3(ans3),
    .ans4(ans4)
);
XTY xty0(
    .clk(clk),
    .rst_n(rst_n), 
    .start(start),
    .xi(inp),
    .xi2(inp2),
    .yi(inpy),
    .out1(ans1),
    .out2(ans2),
    .out3(ans3)
    
);

// input pattern
integer i;

initial begin
    // update weight
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
    //inp <=0;
    for (i=0; i < 5; i=i+1) begin
        start = 1;
        inp = i;
        inp2 =i*i;
        inpy=i
        $display("           Simulation Result      ");
        //$monitor("xi=%d ans0=%d ans1=%d ans2=%d ans3=%d ans4=%d\n",inp, ans0, ans1,ans2,ans3,ans4);
        $monitor("inp=%d inpy=%d ans1=%d ans2=%d ans3=%d\n", inp, ans1,ans2,ans3);
        @(posedge clk);
    end
    inp = 0;
    start = 0;
end

endmodule