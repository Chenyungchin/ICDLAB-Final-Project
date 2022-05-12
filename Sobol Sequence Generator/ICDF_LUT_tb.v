`timescale 1ns/10ps
`define CYCLE 10.0
`define PATTERN 100

module ICDF_LUT_tb;

// ================= clk generation =====================
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ================= dump waveform ======================
// vcd
// initial begin
//     $dumpfile("ICDF.vcd");
//     $dumpvars(0, pe0);
// end
// fsdb
initial begin
    $fsdbDumpfile("ICDF_LUT.fsdb");
    $fsdbDumpvars(0, "+mda");
end

// ================== time out ==========================
initial begin
    # (10000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end

// ================= instantiate DUT ====================
reg          rst_n;
reg  [31:0]  cdf;
wire [15:0]  icdf;
ICDF_LUT icdf_lut0(
    .clk(clk),
    .rst_n(rst_n),
    .cdf(cdf),
    .icdf(icdf)
);

// ============== Initial Memory ====================
reg [31:0]   INPUT_CDF_MEM         [0:`PATTERN-1];
reg [15:0]   GOLDEN_ICDF_MEM       [0:`PATTERN-1];

initial begin
    $readmemh("pattern/ICDF_LUT_pattern/cdf.dat", INPUT_CDF_MEM);
    $readmemh("pattern/ICDF_LUT_pattern/icdf.dat", GOLDEN_ICDF_MEM);
end

// ===== input pattern & result checking ===========
integer i, j;
integer err_num = 0;

// input pattern
initial begin
    rst_n = 1;
    for (i=0; i<10; i=i+1) begin
        @(posedge clk);
    end
    for (i=0; i<`PATTERN; i=i+1) begin
        cdf = INPUT_CDF_MEM[i];
        @(posedge clk);
    end
    cdf = 'bx;
end

// check output
initial begin
    rst_n = 1;
    for (j=0; j<12; j=j+1) begin
        @(negedge clk);
    end
    for (j=0; j<`PATTERN; j=j+1) begin
        if (GOLDEN_ICDF_MEM[j] === icdf && icdf !== 16'bx) begin
            $display("\033[1;92mPattern %3d passed. / Input cdf: %4d / Output icdf: %4d / Golden icdf: %4d\033[0m", j, cdf, icdf, GOLDEN_ICDF_MEM[j]);
        end
        else begin
            $display("\033[1;31mPattern %3d failed. / Input cdf: %4d / Output icdf: %4d / Golden icdf: %4d\033[0m", j, cdf, icdf, GOLDEN_ICDF_MEM[j]);
            err_num = err_num + 1;
        end
        @(negedge clk);
    end

    if (err_num != 0) begin
        $display("\n\033[1;31m=============================================");
		$display("              Simulation failed              ");
		$display("=============================================\033[0m");
    end
    else begin
        $display("\n\033[1;92m=============================================");
		$display("              Simulation passed              ");
		$display("=============================================\033[0m");
    end

    $finish;
end


endmodule