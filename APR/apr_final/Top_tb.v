`timescale 1ns/10ps
`define CYCLE    10           	         // Modify your clock period here

`define PATH     "./path.dat"         // Modify your test image file
// `define IMAGE2     "./data2.dat"         // Modify your test image file
// `define CMD        "./cmd.dat"           // Modify your test cmd file
// `define EXPECT     "./out_golden.dat"    // Modify your output golden file

module MC_CORE_tb;

parameter DATA_LENGTH   = 256;
parameter TOTAL_LENGTH  = 2048;
parameter DAY           = 8;

reg           clk;
reg           reset;
reg   [11:0]  path, K, w, q, S, in;
reg   [1:0]   state;
wire          resend;
wire          valid;
wire  [11:0]  out;


// reg   [2:0]   cmd_mem   [0:DATA_LENGTH-1];
// reg   [15:0]  out_mem   [0:OUT_LENGTH-1];
reg   [11:0]   path_mem  [0:TOTAL_LENGTH-1];
// reg   [7:0]   image2_mem  [0:DATA_LENGTH-1];
reg   [15:0]  out_temp;

reg           stop;
integer       i, out_f, err, pattern_num;
reg           over;
integer       day;
reg           res;

CHIP top0(
.clk(clk),
.rst_n(reset), 
.state(state), 
.in(in),  
.valid(valid), 
.out(out), 
.resend(resend) 
);



//initial $sdf_annotate(`SDFFILE, top);
initial	$readmemh (`PATH,  path_mem);
// initial	$readmemh (`IMAGE2,  image2_mem);
// initial	$readmemh (`CMD,    cmd_mem);
// initial	$readmemh (`EXPECT, out_mem);

initial begin
    clk         = 1'b1;
    reset       = 1'b1;
    state       = 2'b0;
    K           = 12'b001100000000;  
    w           = 12'b010101010101;
    q           = 12'b010110110001;
    S           = 12'b000111101011;
    in          = 12'b000000000000;
    over        = 1'b0;
    pattern_num = 0;
    err         = 0;
    i           = 0;   
    day         = 0;
    res         = 1'b0; // 0 when begin a new day; 1 when resend after regression
    #2.5 reset=1'b0;                            // system reset
    #2.5 reset=1'b1;
    // #2.5 start=1'b1;
    // #2.5 start=1'b0;

end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$fsdbDumpfile("mc_core.fsdb");
	$fsdbDumpvars(0, "+mda");

   out_f = $fopen("out.dat");
   if (out_f == 0) begin
        $display("Output file open error !");
        $finish;
   end
end


always @(negedge clk)begin
	if(i < DATA_LENGTH*(day+1) + 2 && i > DATA_LENGTH*day+1)begin
          path  = path_mem[i-2];
	end
		//  out_temp = out_mem[i];
	i = i+1;      
    if (resend && ~res) begin
        path = path_mem[DATA_LENGTH*day];
        i = DATA_LENGTH*day + 3;
        res = 1'b1;
    end
    else if (resend && res) begin
        day = day + 1;
        path = path_mem[DATA_LENGTH * day];
        i = DATA_LENGTH * day;
        res = 1'b0;
    end
    // else                                       
    //    stop = 1 ;      
end

// always @(posedge clk)begin
    
//     if(dataout !== out_temp && out_temp!==16'h0000) begin
//         $display("ERROR at %d:output %h !=expect %h ",pattern_num-2, dataout, out_temp);
// 	    $fdisplay(out_f,"ERROR at %d:output %h !=expect %h ",pattern_num-2, dataout, out_temp);

//         err = err + 1 ;
//     end
//     pattern_num = pattern_num + 1; 
//     if(pattern_num === OUT_LENGTH)  over = 1'b1;
// end

// initial begin
//       @(posedge stop)      
//       if(over) begin
//          $display("---------------------------------------------\n");
//          if (err == 0)  begin
//             $display("All data have been generated successfully!\n");
// 			$display("You will get 80 score in this RTL!\n");
//             $display("-------------------PASS-------------------\n");
//          end
//          else begin
//             $display("There are %d errors!\n", err);
// 			$display("You will get %d score in this RTL!\n", 80-err);
// 		 end
//             $display("---------------------------------------------\n");
//       end
//       else begin
//         $display("---------------------------------------------\n");
//         $display("Error!!! There is no any data output ...!\n");
//         $display("-------------------FAIL-------------------\n");
//         $display("---------------------------------------------\n");
//       end
//       $finish;
// end
   
initial begin
    # (50000 * `CYCLE);
    $display("\n\033[1;31m=============================================");
	$display("           Simulation Time Out!      ");
	$display("=============================================\033[0m");
	$finish;
end
endmodule









