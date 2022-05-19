`timescale 1ns/10ps
`define CYCLE 10.0
`define PATTERN 100

`define NUM_OF_BUFFERS 1

module Path_Gen_tb;

// ================= clk generation =====================
reg clk = 1;
always #(`CYCLE/2) clk = ~clk;


// ================= dump waveform ======================
// vcd
// initial begin
//     $dumpfile("Path_Gen.vcd");
//     $dumpvars(0, path_gen0);
// end
// fsdb
initial begin
    $fsdbDumpfile("Path_Gen.fsdb");
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
// input
reg          rst_n = 0, start = 0;
reg   [11:0] w = 0, q = 0, S0 = 0;
reg   [12:0] epsilon = 0;
// output 
wire         valid;
wire  [11:0] path;

Path_Gen path_gen0(
    // input
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .w(w),
    .q(q),
    .epsilon(epsilon),
    .S0(S0),
    // output
    .valid(valid),
    .path(path)
);

// ============== Initial Memory ====================
reg [12:0]   INPUT_EPSILON_MEM         [0:8*`PATTERN-1];
reg [35:0]   INPUT_INIT_PAR_MEM        [0:`PATTERN-1];
reg [11:0]   GOLDEN_PATH_MEM           [0:8*`PATTERN-1];

initial begin
    $readmemh("pattern/Path_Gen_pattern/epsilon.dat", INPUT_EPSILON_MEM);
    $readmemh("pattern/Path_Gen_pattern/initial_parameters.dat", INPUT_INIT_PAR_MEM);
    $readmemh("pattern/Path_Gen_pattern/path.dat", GOLDEN_PATH_MEM);
end

// ===== input pattern & result checking ===========
integer i, j;
integer ii, jj;
integer err_num = 0;

reg [11:0] dao;


// input pattern
initial begin
    rst_n = 1;
    @(posedge clk) rst_n = 0;
    @(posedge clk) rst_n = 1;
    for (i=0; i<10; i=i+1) begin
        @(posedge clk);
    end
    for (i=0; i<`PATTERN; i=i+1) begin
        @(negedge clk) begin
            start = 1;
        end
        @(posedge clk);
        w = INPUT_INIT_PAR_MEM[i][35:24];
        q = INPUT_INIT_PAR_MEM[i][23:12];
        S0 = INPUT_INIT_PAR_MEM[i][11:0];
        for (ii=0; ii<8; ii=ii+1) begin
            epsilon = INPUT_EPSILON_MEM[8*i+ii];
            @(negedge clk)begin
                start = 0;
            end
            @(posedge clk);
        end
        @(posedge clk);
        @(posedge clk);
    end
    w = 'bx;
    q = 'bx;
    S0 = 'bx;
    epsilon = 'bx;
end

// check output
initial begin
    @(negedge clk);
    @(negedge clk);
    for (j=0; j<11+`NUM_OF_BUFFERS; j=j+1) begin
        @(negedge clk);
    end
    for (j=0; j<`PATTERN; j=j+1) begin
        @(posedge valid);
        @(negedge clk);
        for (jj=0; jj<8; jj=jj+1) begin
            if (valid) begin
                dao = GOLDEN_PATH_MEM[8*j+jj];
                if (GOLDEN_PATH_MEM[8*j+jj] === path && path !== 12'bx) begin
                    $display("\033[1;92mPattern %3d passed. / Input epsilon: %4d / Output path: %4d / Golden path: %4d\033[0m", 8*j+jj, epsilon, path, GOLDEN_PATH_MEM[8*j+jj]);
                end
                else begin
                    $display("\033[1;31mPattern %3d failed. / Input epsilon: %4d / Output path: %4d / Golden path: %4d\033[0m", 8*j+jj, epsilon, path, GOLDEN_PATH_MEM[8*j+jj]);
                    err_num = err_num + 1;
                end
            end
            @(negedge clk);
        end
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