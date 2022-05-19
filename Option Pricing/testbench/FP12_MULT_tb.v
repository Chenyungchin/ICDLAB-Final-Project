`timescale 1ns/10ps
`define CYCLE 10.0

module FP12_MULT_tb;

// ============= clk generation ================
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ============= dump waveform =================
// fsdb
// initial begin
//     $fsdbDumpfile("FP12_MULT.fsdb");
//     $fsdbDumpvars(0, "+mda");
// end

// vcd
initial begin
    $dumpfile("FP12_MULT.vcd");
    $dumpvars(0, fp12_mult0);
end

// time out
initial begin
    # (10000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end

// instantiate DUT
reg  [11:0] in1 = 0, in2 = 0;
wire [11:0] out;

FP12_MULT fp12_mult0(
    .in1(in1),
    .in2(in2),
    .out(out)
);

// input pattern
// integer i;

initial begin
    // update weight
    @(posedge clk) 
    in1 = 12'b00000011_1000;
    in2 = 12'b00000011_1000;
    @(posedge clk) 
    in1 = 12'b001100001010;
    in2 = 12'b111011000000;
    @(posedge clk) 
    in1 = 12'b0011_11111111;
    in2 = 12'b1110_11111111;
    // @(posedge clk) 
    // in1 = 12'b;
    // @(posedge clk) 
    // in1 = 12'b;
    // @(posedge clk) 
    // in1 = 12'b;
    // @(posedge clk) 
    // in1 = 12'b0;
end

endmodule