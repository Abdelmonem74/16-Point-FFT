module radix2 #(parameter   SAMPLE_WORD_LENGTH  = 8, SAMPLE_INT_LENGTH  = 0, SAMPLE_FLOAT_LENGTH  = 7, 
                            TWIDDLE_WORD_LENGTH = 8, TWIDDLE_INT_LENGTH = 0, TWIDDLE_FLOAT_LENGTH = 7) (

    output reg  signed [SAMPLE_WORD_LENGTH -1 :0] out1_i_reg,
    output reg  signed [SAMPLE_WORD_LENGTH -1 :0] out1_q_reg,
    output reg  signed [SAMPLE_WORD_LENGTH -1 :0] out2_i_reg,
    output reg  signed [SAMPLE_WORD_LENGTH -1 :0] out2_q_reg,

    input  wire signed [SAMPLE_WORD_LENGTH -1 :0] in1_i,
    input  wire signed [SAMPLE_WORD_LENGTH -1 :0] in1_q,
    input  wire signed [SAMPLE_WORD_LENGTH -1 :0] in2_i,
    input  wire signed [SAMPLE_WORD_LENGTH -1 :0] in2_q,

    input  wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle1_i,
    input  wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle1_q,
    input  wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle2_i,
    input  wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle2_q,

    input  wire                                   ff_en,
    input  wire                                   rst,
    input  wire                                   clk
);

reg  signed [SAMPLE_WORD_LENGTH+1 -1 :0] adder_i_out1,adder_q_out1,adder_i_out2,adder_q_out2;
wire signed [SAMPLE_WORD_LENGTH   -1 :0] out1_i,out1_q,out2_i,out2_q;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        out1_i_reg <= 'd0;
        out1_q_reg <= 'd0;
        out2_i_reg <= 'd0;
        out2_q_reg <= 'd0;
    end
    else begin
        if (ff_en) begin
            out1_i_reg <= out1_i;
            out1_q_reg <= out1_q;
            out2_i_reg <= out2_i;
            out2_q_reg <= out2_q;
        end
    end
end

always @(*) begin
    adder_i_out1  = in1_i + in2_i;
    adder_q_out1  = in1_q + in2_q;

    adder_i_out2  = in1_i - in2_i;
    adder_q_out2  = in1_q - in2_q;

    
end

cmplx_mul #(    .IN1_WORD_LENGTH(SAMPLE_WORD_LENGTH+1) , .IN1_INT_LENGTH(SAMPLE_INT_LENGTH+1) , .IN1_FLOAT_LENGTH(SAMPLE_FLOAT_LENGTH ) ,
                .IN2_WORD_LENGTH(TWIDDLE_WORD_LENGTH ) , .IN2_INT_LENGTH(TWIDDLE_INT_LENGTH ) , .IN2_FLOAT_LENGTH(TWIDDLE_FLOAT_LENGTH) ,
                .OUT_WORD_LENGTH(SAMPLE_WORD_LENGTH  ) , .OUT_INT_LENGTH(SAMPLE_INT_LENGTH  ) , .OUT_FLOAT_LENGTH(SAMPLE_FLOAT_LENGTH ) ) 
U1 (
    .out_i (out1_i),
    .out_q (out1_q),
    .in1_i (adder_i_out1),
    .in1_q (adder_q_out1),
    .in2_i (twiddle1_i),
    .in2_q (twiddle1_q)
);

cmplx_mul #(    .IN1_WORD_LENGTH(SAMPLE_WORD_LENGTH+1) , .IN1_INT_LENGTH(SAMPLE_INT_LENGTH+1) , .IN1_FLOAT_LENGTH(SAMPLE_FLOAT_LENGTH ) ,
                .IN2_WORD_LENGTH(TWIDDLE_WORD_LENGTH ) , .IN2_INT_LENGTH(TWIDDLE_INT_LENGTH ) , .IN2_FLOAT_LENGTH(TWIDDLE_FLOAT_LENGTH) ,
                .OUT_WORD_LENGTH(SAMPLE_WORD_LENGTH  ) , .OUT_INT_LENGTH(SAMPLE_INT_LENGTH  ) , .OUT_FLOAT_LENGTH(SAMPLE_FLOAT_LENGTH ) ) 
U2 (                    
    .out_i (out2_i),
    .out_q (out2_q),
    .in1_i (adder_i_out2),
    .in1_q (adder_q_out2),
    .in2_i (twiddle2_i),
    .in2_q (twiddle2_q)
);

endmodule

/*
force -freeze sim:/radix2/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/radix2/rst 1 0
force -freeze sim:/radix2/rst 0 5
force -freeze sim:/radix2/rst 1 10
force -freeze sim:/radix2/ff_en 1 0
force -freeze sim:/radix2/twiddle2_q 0 0
force -freeze sim:/radix2/twiddle1_q 0 0
force -freeze sim:/radix2/in2_q 0 0
force -freeze sim:/radix2/in1_q 0 0
force -freeze sim:/radix2/in1_i 8'b01000000 0
force -freeze sim:/radix2/in2_i 8'b00100000 0
force -freeze sim:/twiddle1_i/in1_i 8'b01000000 0
force -freeze sim:/twiddle2_i/in1_i 8'b01000000 0
*/