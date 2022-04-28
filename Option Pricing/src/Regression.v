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
endmodule