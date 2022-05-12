module Regression(
    input         clk,
    input         rst_n, 
    input  [11:0] xi, 
    input  [11:0] yi, 
    output        valid, 
    output [11:0] expected_profit
);

// Input is profit (path - K). Total number of profits is N. 
// XTX: Store the profits and build X (N*2), and compute XTX (2*2). ans0 is sigma(1), ans1 is sigma(xi), ans2 is sigma(xi^2)
// XTY: 

localparam N = 256;


always @(*) begin


end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin

    end
    else begin
    
    end
end

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

MAT_INV inv0(
    .clk(clk),
    .rst_n(rst_n), 
    .start(start),
    .sig0(),
    .sig1(),
    .sig2(),
    .out0(),
    .out1(),
    .out2()
);
endmodule