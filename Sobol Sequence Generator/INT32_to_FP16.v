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
    // MSO = 11;
    // for (i=12; i<32; i=i+1) begin
    //     if (int32_val[i] == 1) MSO = i;
    // end

    casex (int32_val)
        32'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd31;
        32'b01xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd30;
        32'b001xxxxxxxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd29;
        32'b0001xxxxxxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd28;
        32'b00001xxxxxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd27;
        32'b000001xxxxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd26;
        32'b0000001xxxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd25;
        32'b00000001xxxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd24;
        32'b000000001xxxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd23;
        32'b0000000001xxxxxxxxxxxxxxxxxxxxxx: MSO = 5'd22;
        32'b00000000001xxxxxxxxxxxxxxxxxxxxx: MSO = 5'd21;
        32'b000000000001xxxxxxxxxxxxxxxxxxxx: MSO = 5'd20;
        32'b00000000000001xxxxxxxxxxxxxxxxxx: MSO = 5'd19;
        32'b000000000000001xxxxxxxxxxxxxxxxx: MSO = 5'd18;
        32'b0000000000000001xxxxxxxxxxxxxxxx: MSO = 5'd17;
        32'b00000000000000001xxxxxxxxxxxxxxx: MSO = 5'd16;
        32'b000000000000000001xxxxxxxxxxxxxx: MSO = 5'd15;
        32'b0000000000000000001xxxxxxxxxxxxx: MSO = 5'd14;
        32'b00000000000000000001xxxxxxxxxxxx: MSO = 5'd13;
        32'b000000000000000000001xxxxxxxxxxx: MSO = 5'd12;
        32'b0000000000000000000001xxxxxxxxxx: MSO = 5'd11;
        default: MSO = 5'd10;
    endcase
end


endmodule