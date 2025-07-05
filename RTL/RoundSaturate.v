module RoundSaturate #(parameter    IN_WORD_LENGTH    = 9,  IN_INT_LENGTH    = 0, IN_FLOAT_LENGTH    = 8, 
                                    OUT_WORD_LENGTH   = 8, OUT_INT_LENGTH   = 0, OUT_FLOAT_LENGTH   = 7) (


    output reg  signed [OUT_WORD_LENGTH-1:0] i_round_saturated,
    output reg  signed [OUT_WORD_LENGTH-1:0] q_round_saturated,
    input  wire signed [IN_WORD_LENGTH -1:0] i_in,
    input  wire signed [IN_WORD_LENGTH -1:0] q_in
    
);


//INPUT  NOTATION ---> SX.Y
//OUTPUT NOTATION ---> SA.B
//
//in this module we have A<X and/or B<Y 
//so we have to do (ROUND & SATURATION) to minimize the error due to TRUNCATION of some input bits
//
//We do the following to get the ouput...
//
// 1.    S is the most bit of the INPUT
// 2.    A is the least bits of X
// 3.    B is the most bits of Y
//
// 4.    ROUND HALF UP , MEANS adding the MSB of the truncated floating part to A
//       EXAMPLE: INPUT = S1.4 = 00.0011 , OUTPUT SIZE = S1.3
//                OUTPUT SIGN = 0, OUTPUT INTEGER = 0, OUTPUT FLOAT = 001 + 1 = 010 ---> OUTPUT = 00.010
//                
// 5.    SATURATE the OUTPUT if the following two conditions occured (all of them)
//       1- A < X
//       2- The value stored in X > the value stored in A
//       3- The SIGN = 0 (POSITIVE NUMBER ONLY)
//          Example: INPUT = S2.1 = 010.1 , OUTPUT SIZE = S1.1
//                   OUTPUT SIGN = 0, A = 0
//                   in this case A<X (0<2) , so the OUTPUT = S1.1 = 01.1
//       
//

wire round_half_up_i;
wire round_half_up_q;
reg saturate_i;
reg saturate_q;


generate
    if (OUT_INT_LENGTH) begin
        assign round_half_up_i    = i_in[IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1] && (~i_in[IN_FLOAT_LENGTH + OUT_INT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]);
        assign round_half_up_q    = q_in[IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1] && (~q_in[IN_FLOAT_LENGTH + OUT_INT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]);
    end
    else begin
        assign round_half_up_i    = i_in[IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1] && (~i_in[IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH]); 
        assign round_half_up_q    = q_in[IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1] && (~q_in[IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH]);
    end
endgenerate


generate
        if (IN_INT_LENGTH>0 && OUT_INT_LENGTH >0) begin
            always @(*) begin                   

                //                                {  Sign                                       ,      Integer                                                    ,     Float}
                //                                {  most bit                                   ,      least bits of integer                                      ,     most bits of float } 
                //                                {  IN[1+(X+Y)-1]                              ,      IN[Y+A-1:Y]                                                ,     IN[Y-1 : Y-B] }
                i_round_saturated = round_half_up_i + {i_in[IN_WORD_LENGTH -1] ,    i_in[IN_FLOAT_LENGTH + OUT_INT_LENGTH -1 : IN_FLOAT_LENGTH ] ,   i_in[ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]};
                q_round_saturated = round_half_up_q + {q_in[IN_WORD_LENGTH -1] ,    q_in[IN_FLOAT_LENGTH + OUT_INT_LENGTH -1 : IN_FLOAT_LENGTH ] ,   q_in[ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]};

                
                if (i_in[IN_WORD_LENGTH -1]) begin
                    if (!(i_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH] == 'd0 || i_in[IN_INT_LENGTH  + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH + OUT_INT_LENGTH] == { ( IN_INT_LENGTH - OUT_INT_LENGTH ) {1'b1} }  )) begin
                        i_round_saturated = {i_in[IN_WORD_LENGTH -1] , { (OUT_WORD_LENGTH -1) {1'b0}} } ;
                    end
                end
                else begin
                    if (i_in[IN_INT_LENGTH  + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH + OUT_INT_LENGTH] ) begin
                       i_round_saturated [OUT_WORD_LENGTH -2:0] = { (OUT_WORD_LENGTH -1) {1'b1}} ;
                    end
                end

                if (q_in[IN_WORD_LENGTH -1]) begin
                    if ((!(q_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH] == 'd0 || q_in[IN_INT_LENGTH  + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH + OUT_INT_LENGTH] == { ( IN_INT_LENGTH - OUT_INT_LENGTH ) {1'b1} }  ))) begin
                        q_round_saturated = {q_in[IN_WORD_LENGTH -1] , { (OUT_WORD_LENGTH -1) {1'b0}} } ;
                    end
                end
                else begin
                    if (q_in[IN_INT_LENGTH + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH + OUT_INT_LENGTH]) begin
                       q_round_saturated [OUT_WORD_LENGTH -2:0] = { (OUT_WORD_LENGTH -1) {1'b1}};
                    end
                end 

                if (i_in == { (IN_WORD_LENGTH -1) {1'b1}}) begin
                    i_round_saturated = { (OUT_WORD_LENGTH -1) {1'b0}} ;
                end
                if (q_in == { (IN_WORD_LENGTH -1) {1'b1}}) begin
                    q_round_saturated = { (OUT_WORD_LENGTH -1) {1'b0}};
                end
            end
        end
        else if ((IN_INT_LENGTH>0) && (OUT_INT_LENGTH == 0)) begin
            always @(*) begin

        
                                  

                //                                {  Sign                                           ,     Float}
                //                                {  most bit                                       ,     most bits of float } 
                //                                {  IN[1+(X+Y)-1]                                  ,     IN[Y-1 : Y-B] }
                i_round_saturated = round_half_up_i + {i_in[IN_WORD_LENGTH -1] ,   i_in[ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]};
                q_round_saturated = round_half_up_q + {q_in[IN_WORD_LENGTH -1] ,   q_in[ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]};


                if (i_in[IN_WORD_LENGTH -1]) begin
                    //if ((!(i_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH] == 'd0 || i_in[IN_INT_LENGTH  + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH + OUT_INT_LENGTH] == { ( IN_INT_LENGTH - OUT_INT_LENGTH ) {1'b1} }  ))) begin
                    //    i_round_saturated = {i_in[IN_WORD_LENGTH -1] , { (OUT_WORD_LENGTH -1) {1'b0}} };
                    //end
                    if (!(&i_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH])) begin
                        i_round_saturated = {i_in[IN_WORD_LENGTH -1] , { (OUT_WORD_LENGTH -1) {1'b0}} };
                    end
                    if (&i_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1]) begin
                        i_round_saturated = { (OUT_WORD_LENGTH -1) {1'b0}};
                    end
                end
                else begin
                    if (i_in[IN_INT_LENGTH  + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH ]) begin
                       i_round_saturated [OUT_WORD_LENGTH -2:0] = { (OUT_WORD_LENGTH -1) {1'b1}}; 
                    end
                    if (&i_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH]) begin
                        i_round_saturated = { (OUT_WORD_LENGTH -1) {1'b1}};
                    end
                end

                if (q_in[IN_WORD_LENGTH -1]) begin
                    //if ((!(q_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH] == 'd0 || q_in[IN_INT_LENGTH  + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH + OUT_INT_LENGTH] == { ( IN_INT_LENGTH - OUT_INT_LENGTH ) {1'b1} }  ))) begin
                    //    q_round_saturated = {q_in[IN_WORD_LENGTH -1] , { (OUT_WORD_LENGTH -1) {1'b0}} };
                    //end
                    if (!(&q_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH])) begin
                        q_round_saturated = {q_in[IN_WORD_LENGTH -1] , { (OUT_WORD_LENGTH -1) {1'b0}} };
                    end
                    if (&q_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1]) begin
                        q_round_saturated = {(OUT_WORD_LENGTH -1){1'b0}};
                    end
                end
                else begin
                    if (q_in[IN_INT_LENGTH + IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH]) begin
                       q_round_saturated [OUT_WORD_LENGTH -2:0] = { (OUT_WORD_LENGTH -1) {1'b1}};
                    end
                    if (&q_in[IN_FLOAT_LENGTH + IN_INT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH]) begin
                        q_round_saturated = {(OUT_WORD_LENGTH -1){1'b1}};
                    end
                end  
            end
        end
        else begin
            always @(*) begin
                i_round_saturated =   round_half_up_i +  {i_in[IN_WORD_LENGTH -1] ,i_in[ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]};
                q_round_saturated =   round_half_up_q +  {q_in[IN_WORD_LENGTH -1] ,q_in[ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH ]};

                if (&i_in[1+ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1]) begin
                    i_round_saturated = { (OUT_WORD_LENGTH -1) {1'b0}};
                end
                if (&q_in[1+ IN_FLOAT_LENGTH -1 : IN_FLOAT_LENGTH - OUT_FLOAT_LENGTH -1]) begin
                    q_round_saturated = { (OUT_WORD_LENGTH -1) {1'b0}};
                end
            end
        end
endgenerate




    
endmodule