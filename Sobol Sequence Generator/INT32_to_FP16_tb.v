`timescale 1ns/10ps
`define CYCLE 10.0

module INT32_to_FP16_tb;

// ============= clk generation ================
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ============= dump waveform =================
// fsdb
// initial begin
//     $fsdbDumpfile("INT32_to_FP16.fsdb");
//     $fsdbDumpvars(0, "+mda");
// end

// vcd
initial begin
    $dumpfile("INT32_to_FP16.vcd");
    $dumpvars(0, int32_to_fp16_0);
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
reg  [31:0] int32_val = 0;
wire [15:0] fp16_val;

INT32_to_FP16 int32_to_fp16_0(
    .int32_val(int32_val),
    .fp16_val(fp16_val)
);

// input pattern
// integer i;

initial begin
    // update weight
    @(posedge clk) int32_val = 32'b00000011001100100000000000000000;
    @(posedge clk) int32_val = 32'b00000110110001000000000000000000;
    @(posedge clk) int32_val = 32'b00001101100010000000000000000000;
    @(posedge clk) int32_val = 32'b00011011110100000000000000000000;
    @(posedge clk) int32_val = 32'b00110111011000000000000000000000;
    @(posedge clk) int32_val = 32'b01101111010000000000000000000000;
    @(posedge clk) int32_val = 32'b00000000000000000000000000111100;
end

endmodule