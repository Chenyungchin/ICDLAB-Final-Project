module Regression(
    input         clk,
    input         rst_n, 
    input  [11:0] profit, 
    output        valid, 
    output [11:0] expected_profit
);

localparam N = 128;


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

endmodule