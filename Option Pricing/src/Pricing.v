module Pricing(
    input         clk,
    input         rst_n, 
    input  [11:0] path, 
    output [11:0] price
);





always @(*) begin


end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin

    end
    else begin
    
    end
end
endmodule