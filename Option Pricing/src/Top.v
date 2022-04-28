module Top(
    input         clk,
    input         rst_n, 
    input  [1:0]  state, 
    input  [11:0] in, 
    output [15:0] out
);

    always @(*) begin


    end


    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin

        end
        else begin
        
        end
    end


    Sobol sobol0(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .res0(res0),
        .res1(res1),
        .res2(res2),
        .res3(res3)
    );

    Path_Gen path_gen0(

    );

    Pricing pricing0(

    );
endmodule