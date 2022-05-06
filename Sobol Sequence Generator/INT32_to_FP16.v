// transfer the INT32 value from Sobol to FP16
// modified FP16 scheme: 5 bits for exponent and 11 bits for mantissa (no sign bit since there are only positive values)
// exponent: the bit of the most significant one (be 10 if MSO <= 10)
// mantissa: counting 12 bits starting from exponent 
module INT32_to_FP16(
    input  [31:0] int32_val,
    output [15:0] fp16_val
);

// ========== parameters ==============
integer i;
// ========== wire and reg ============
wire  [4:0] exponent;
wire [10:0] mantissa;
// most significant one
reg   [4:0] MSO;

// ========== assignments =============
assign fp16_val = {exponent, mantissa};

assign exponent = MSO;
assign mantissa = int32_val[MSO -: 11];

// ========== Combinational ===========
always @(*) begin
    MSO = 10;
    for (i=12; i<32; i=i+1) begin
        if (int32_val[i] == 1) MSO = i;
    end
end


endmodule