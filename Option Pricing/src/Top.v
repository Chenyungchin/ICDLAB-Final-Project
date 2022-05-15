module Top(
    input         clk,
    input         rst_n, 
    input  [1:0]  state, 
    input  [11:0] in, 
    output [15:0] out
);

// ========== wire and reg ====================
// Sobol
wire  [12:0] icdf;
// ========== Combinational ===================
always @(*) begin


end

// ========== Sequential ======================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin

    end
    else begin
    
    end
end

// ========== Module Instantiation ============
Sobol sobol0(
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .icdf(icdf)
);

Path_Gen path_gen0(
    // input
    .clk(clk),
    .rst_n(rst_n),
    .w(),
    .q(),
    .epsilon(icdf),
    .S0(),
    // output
    .valid(),
    .path()
);

Pricing pricing0(

);
endmodule