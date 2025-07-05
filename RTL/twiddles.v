module twiddles #(parameter TWIDDLE_WORD_LENGTH = 8, TWIDDLE_INT_LENGTH = 0, TWIDDLE_FLOAT_LENGTH = 7) (
    output reg  signed  [TWIDDLE_WORD_LENGTH -1 : 0] twiddle_i_reg,
    output reg  signed  [TWIDDLE_WORD_LENGTH -1 : 0] twiddle_q_reg,
    input  wire         [3                   -1 : 0] address,
    input  wire         clk,
    input  wire         rst
);

reg signed [TWIDDLE_WORD_LENGTH -1 : 0] twiddle_i;
reg signed [TWIDDLE_WORD_LENGTH -1 : 0] twiddle_q;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        twiddle_i_reg <= 'd0;
        twiddle_q_reg <= 'd0;
    end
    else begin
        twiddle_i_reg <= twiddle_i;
        twiddle_q_reg <= twiddle_q;
    end
end

always @(*) begin
    case (address)
        'd0 :   begin 
                    twiddle_i = 8'b01111111; 
                    twiddle_q = 8'b00000000; 
                end
        'd1 :   begin
                    twiddle_i = 8'b01110110; //A
                    twiddle_q = 8'b11001111; //B
                end
        'd2 :   begin
                    twiddle_i = 8'b01011011;
                    twiddle_q = 8'b10100101;
                end 
        'd3 :   begin
                    twiddle_i = 8'b00110001; //B
                    twiddle_q = 8'b10001010; //A
                end
        'd4 :   begin
                    twiddle_i = 8'b00000000; 
                    twiddle_q = 8'b10000000; 
                end 
        'd5 :   begin
                    twiddle_i = 8'b11001111; 
                    twiddle_q = 8'b10001010; 
                end 
        'd6 :   begin
                    twiddle_i = 8'b10100101; 
                    twiddle_q = 8'b10100101; 
                end 
        'd7 :   begin
                    twiddle_i = 8'b10001010; 
                    twiddle_q = 8'b11001111; 
                end   
        
    endcase
end


endmodule