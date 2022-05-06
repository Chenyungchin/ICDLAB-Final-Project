module Sobol_to_INT32(
    input             clk,
    input             rst_n, 
    input             start,
    output reg [31:0] res
);
// ================== parameter =========================
parameter IDLE = 1'b0;
parameter COMP = 1'b1;
// DVA31, DVA30 , ......, DVA1, DVA0
parameter [32*32-1:0] DVA = {
    32'b00000000000000000000000111110011,
    32'b00000000000000000000001100110010,
    32'b00000000000000000000011011000100,
    32'b00000000000000000000110110001000,
    32'b00000000000000000001101111010000,
    32'b00000000000000000011011101100000,
    32'b00000000000000000110111101000000,
    32'b00000000000000001101111110000000,
    32'b00000000000000000100110100000000,
    32'b00000000000000000100111000000000,
    32'b00000000000000000011110000000000,
    32'b00000000000000000111100000000000,
    32'b00000000000000000011000000000000,
    32'b00000000000000001010000000000000,
    32'b00000000000000001100000000000000,
    32'b00000000000000001000000000000000,
    32'b00000001111100110000000000000000,
    32'b00000011001100100000000000000000,
    32'b00000110110001000000000000000000,
    32'b00001101100010000000000000000000,
    32'b00011011110100000000000000000000,
    32'b00110111011000000000000000000000,
    32'b01101111010000000000000000000000,
    32'b11011111100000000000000000000000,
    32'b01001101000000000000000000000000,
    32'b01001110000000000000000000000000,
    32'b00111100000000000000000000000000,
    32'b01111000000000000000000000000000,
    32'b00110000000000000000000000000000,
    32'b10100000000000000000000000000000,
    32'b11000000000000000000000000000000,
    32'b10000000000000000000000000000000
};


// ================== reg and wire ======================
// reg   [31:0] res0, res1, res2, res3;
wire  [31:0] res_w;

reg          state, state_ns;

reg   [31:0] counter;
reg   [4:0] LSZ;

integer i;

// ================== wire assignments ==================
assign res_w = res ^ DVA[32*(LSZ+1)-1 -: 32];

// ================== Combinational =====================
// state
always @(*) begin
    state_ns = state;
    case (state_ns)
        IDLE: begin
            if (start) state_ns = COMP;
        end 
        COMP: begin
            
        end
        default: begin
            
        end
    endcase
end
// counter 
always @(*) begin

    // for (i=0; i < 32; i = i+1) begin
    //     if (counter[31 - i] == 0) LSZ = 31 - i;
    // end

    ///////LSZ is a latch, modified as below///////
    casex (counter)
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0: LSZ = 5'd0;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx01: LSZ = 5'd1;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx011: LSZ = 5'd2;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx0111: LSZ = 5'd3;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxxx01111: LSZ = 5'd4;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxxx011111: LSZ = 5'd5;
        32'bxxxxxxxxxxxxxxxxxxxxxxxxx0111111: LSZ = 5'd6;
        32'bxxxxxxxxxxxxxxxxxxxxxxxx01111111: LSZ = 5'd7;
        32'bxxxxxxxxxxxxxxxxxxxxxxx011111111: LSZ = 5'd8;
        32'bxxxxxxxxxxxxxxxxxxxxxx0111111111: LSZ = 5'd9;
        32'bxxxxxxxxxxxxxxxxxxxxx01111111111: LSZ = 5'd10;
        32'bxxxxxxxxxxxxxxxxxxxx011111111111: LSZ = 5'd11;
        32'bxxxxxxxxxxxxxxxxxxx0111111111111: LSZ = 5'd12;
        32'bxxxxxxxxxxxxxxxxxx01111111111111: LSZ = 5'd13;
        32'bxxxxxxxxxxxxxxxxx011111111111111: LSZ = 5'd14;
        32'bxxxxxxxxxxxxxxxx0111111111111111: LSZ = 5'd15;
        32'bxxxxxxxxxxxxxxx01111111111111111: LSZ = 5'd16;
        32'bxxxxxxxxxxxxxx011111111111111111: LSZ = 5'd17;
        32'bxxxxxxxxxxxxx0111111111111111111: LSZ = 5'd18;
        32'bxxxxxxxxxxxx01111111111111111111: LSZ = 5'd19;
        32'bxxxxxxxxxxx011111111111111111111: LSZ = 5'd20;
        32'bxxxxxxxxxx0111111111111111111111: LSZ = 5'd21;
        32'bxxxxxxxxx01111111111111111111111: LSZ = 5'd22;
        32'bxxxxxxxx011111111111111111111111: LSZ = 5'd23;
        32'bxxxxxxx0111111111111111111111111: LSZ = 5'd24;
        32'bxxxxxx01111111111111111111111111: LSZ = 5'd25;
        32'bxxxxx011111111111111111111111111: LSZ = 5'd26;
        32'bxxxx0111111111111111111111111111: LSZ = 5'd27;
        32'bxxx01111111111111111111111111111: LSZ = 5'd28;
        32'bxx011111111111111111111111111111: LSZ = 5'd29;
        32'bx0111111111111111111111111111111: LSZ = 5'd30;
        32'b01111111111111111111111111111111: LSZ = 5'd31;
        default: LSZ = 5'd0;
    endcase 
end


// ================== sequential ========================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        res     <= 32'b0;
        counter <= 32'b0;
        state   <= IDLE;
    end
    else begin
        state <= state_ns;
        if (state == COMP) begin
            res     <= res_w;
            counter <= counter + 32'b1;
        end
        else begin
            res     <= 32'b0;
            counter <= 32'b0;
        end
    end
end

endmodule