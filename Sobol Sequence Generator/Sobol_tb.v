`timescale 1ns/10ps
`define CYCLE 10.0

module Sobol_tb;

// ============= clk generation ================
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ============= dump waveform =================
// fsdb
// initial begin
//     $fsdbDumpfile("Sobol.fsdb");
//     $fsdbDumpvars(0, "+mda");
// end

// vcd
initial begin
    $dumpfile("Sobol.vcd");
    $dumpvars(0, sobol0);
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
reg          rst_n = 1;
reg          start = 0;
wire [15:0]  icdf;

Sobol sobol0(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .icdf(icdf)
);

// input pattern
integer i;

initial begin
    // update weight
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
    for (i=0; i < 5; i=i+1) begin
        @(posedge clk);
    end
    start <= 1;
end

endmodule