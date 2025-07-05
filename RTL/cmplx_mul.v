module cmplx_mul #(parameter    IN1_WORD_LENGTH = 16, IN1_INT_LENGTH = 0, IN1_FLOAT_LENGTH = 15,        // S0.7   

                                IN2_WORD_LENGTH = 5,  IN2_INT_LENGTH = 0, IN2_FLOAT_LENGTH = 4,        // S0.4

                                OUT_WORD_LENGTH = 12, OUT_INT_LENGTH = 0, OUT_FLOAT_LENGTH = 11 ) (    // S0.14

    output wire signed [OUT_WORD_LENGTH-1:0]    out_i,
    output wire signed [OUT_WORD_LENGTH-1:0]    out_q,

    input  wire signed [IN1_WORD_LENGTH-1:0]    in1_i,
    input  wire signed [IN1_WORD_LENGTH-1:0]    in1_q,

    input  wire signed [IN2_WORD_LENGTH-1:0]    in2_i,
    input  wire signed [IN2_WORD_LENGTH-1:0]    in2_q
);

//WE WANT TO APPLY COMPLEX MULTIPLICATION : IN1_r = (in1_i+j in1_q) * conj(in2_i + j in2_q) 
//
//FIRST METHOD SIMPLIFIES TO : IN1_r = [(in1_i * in2_i) + (in1_q * in2_q)] + j [(-in1_i * in2_q) + (in1_q * in2_i)]
//               HENCE WE NEED (4 MULTIPLIERS + 3 ADDERS)
//
//SECOND METHOD SIMPLIFIES TO : IN1_r = [in1_i * (in2_i - in2_q) + in2_q * (in1_i + in1_q)] + j [in1_i * (in2_i - in2_q) + in2_i * (in1_q - in1_i)]
//                HENCE WE NEED (3 MULTIPLIERS + 5 ADDERS)
//
//IN THIS MODULE WE USE THE SECOND APPROACH


//in1_i/q    = SX.Y
//in2_i/q    = SA.B
//out_i/q   = SG.Z

// S(X+A+1).(Y+B) + S(X+A+1).(Y+B) = S(X+A+2).(Y+B)
reg signed [1 + IN1_INT_LENGTH + IN2_INT_LENGTH + 2 + IN1_FLOAT_LENGTH + IN2_FLOAT_LENGTH -1:0] mul_i;
reg signed [1 + IN1_INT_LENGTH + IN2_INT_LENGTH + 2 + IN1_FLOAT_LENGTH + IN2_FLOAT_LENGTH -1:0] mul_q;



reg signed [IN2_WORD_LENGTH-1 +1 :0]    temp1; // SA.B + SA.B = S(A+1).(B)   
reg signed [IN1_WORD_LENGTH-1 +1 :0]    temp2; // SX.Y + SX.Y = S(X+1).(Y)
reg signed [IN1_WORD_LENGTH-1 +1 :0]    temp3; // SX.Y + SX.Y = S(X+1).(Y)   


// S(A+1).(B)   * SX.Y = S(X+A+1).(Y+B)
reg signed [1 + IN1_INT_LENGTH + IN2_INT_LENGTH + 1 + IN1_FLOAT_LENGTH + IN2_FLOAT_LENGTH -1:0]    temp11;  

// [S(X+1).(Y)] * SA.B = S(X+A+1).(Y+B) 
reg signed [1 + IN1_INT_LENGTH + IN2_INT_LENGTH + 1 + IN1_FLOAT_LENGTH + IN2_FLOAT_LENGTH -1:0]    temp22; 

// S(X+1).(Y)   * SA.B = S(X+A+1).(Y+B)
reg signed [1 + IN1_INT_LENGTH + IN2_INT_LENGTH + 1 + IN1_FLOAT_LENGTH + IN2_FLOAT_LENGTH -1:0]    temp33; 


always @(*) begin

        temp1 = in2_i + in2_q;
        temp2 = in1_i + in1_q;
        temp3 = in1_q - in1_i;

        temp11 = temp1 * in1_i;
        temp22 = temp2 * in2_q;
        temp33 = temp3 * in2_i;

        mul_i = temp11 - temp22;
        mul_q = temp11 + temp33;
end






RoundSaturate #(    .IN_WORD_LENGTH(1 + IN1_INT_LENGTH + IN2_INT_LENGTH + 2 + IN1_FLOAT_LENGTH + IN2_FLOAT_LENGTH) ,
                    .IN_INT_LENGTH(IN1_INT_LENGTH + IN2_INT_LENGTH + 2),
                    .IN_FLOAT_LENGTH(IN1_FLOAT_LENGTH + IN2_FLOAT_LENGTH),
                    .OUT_WORD_LENGTH(OUT_WORD_LENGTH), 
                    .OUT_INT_LENGTH(OUT_INT_LENGTH), 
                    .OUT_FLOAT_LENGTH(OUT_FLOAT_LENGTH) ) U0_RoundSaturate (
    
    .i_in(mul_i),
    .q_in(mul_q),
    .i_round_saturated(out_i),
    .q_round_saturated(out_q)

);


endmodule



//SX.Y + SA.B = S( max(X,A)+1 ).( max(Y,B) )
//SX.Y + SX.Y = S(X+1).(Y) ----> S(X).(Y)

//SX.Y * SA.B = S(X+A).(Y+B)
//SX.Y * SX.Y = S(2X).(2Y)





//SX.Y + SA.B = S( max(X,A)+1 ).( max(Y,B) )
//SX.Y + SX.Y = S(X+1).(Y) ----> S(X).(Y)

//SX.Y * SA.B = S(X+A).(Y+B)
//SX.Y * SX.Y = S(2X).(2Y)



