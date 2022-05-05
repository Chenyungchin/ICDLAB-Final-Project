// transfer the INT32 value from Sobol to FP16
// modified FP16 scheme: 4 bits for exponent and 12 bits for mantissa (no sign bit since there are only positive values)
// exponent: the bit of the most significant one (be 11 if MSO <= 11)
// mantissa: counting 12 bits starting from exponent 
module INT32_to_FP16(
    input  [31:0] int32_val,
    output [15:0] fp16_val
);

// ========== parameters ==============
integer i;
// ========== wire and reg ============
wire  [3:0] exponent;
wire [11:0] mantissa;
// most significant one
reg   [4:0] MSO;

// ========== assignments =============
assign fp16_val = {exponent, mantissa};

assign exponent = MSO;
assign mantissa = int32_val[MSO -: 12];

// ========== Combinational ===========
always @(*) begin
    MSO = 11;
    for (i=12; i<32; i=i+1) begin
        if (int32_val[i] == 1) MSO = i;
    end
end


endmodule