module ctrl #( parameter FIFO_DEPTH = 8) (
    output reg   [3                  -1:0]  twiddle_addr,
    output reg   [5                  -1:0]  counter_r,
    output reg                              fifo1_w_en,
    output reg                              fifo2_w_en,
    output reg                              twiddle_sel,
    output reg                              fifo1_r_en,
    output reg                              fifo2_r_en,
    output wire                             stage_num,
    output wire                             fft_done,
    input  wire  [$clog2(FIFO_DEPTH)  -1:0] r_ptr1,
    input  wire  [$clog2(FIFO_DEPTH)  -1:0] r_ptr2,
    input  wire  [$clog2(FIFO_DEPTH)  -1:0] w_ptr1,
    input  wire  [$clog2(FIFO_DEPTH)  -1:0] w_ptr2,
    input  wire                             fft_strt,
    input  wire                             fifo1_full,
    input  wire                             fifo2_full,
    input  wire                             fifo1_empty,
    input  wire                             fifo2_empty,
    input  wire                             rst,
    input  wire                             clk
);

reg [3 -1 : 0] current_state,next_state;
reg [5 -1 : 0] counter;
reg [2 -1 : 0] stg2_counter,stg2_counter_r;
reg stage1_done, stage2_done, stage3_done, stage4_done ;



localparam  IDLE   = 3'b000,
            STAGE1 = 3'b001,
            STAGE2 = 3'b010,
            STAGE3 = 3'b011,
            STAGE4 = 3'b100;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        current_state  <= 'd0;
        counter_r      <= 'd0;
        stg2_counter_r <= 'd0;
    end
    else begin
        current_state  <= next_state;
        counter_r      <= counter;
        stg2_counter_r <= stg2_counter;
    end
end

always @(*) begin
    case (current_state)
        IDLE :      begin
                        if (fft_strt) begin
                            next_state = STAGE1;
                            counter = counter_r + 'd1;
                        end
                        else begin
                            next_state = IDLE;
                            counter    = 'd0;
                        end
                        stg2_counter   =  'd0;
                        twiddle_sel    = 1'b1;
                        twiddle_addr   =  'd0;
                        fifo1_w_en     =  'd0;
                        fifo2_w_en     =  'd0;
                        fifo1_r_en     =  'd0;
                        fifo2_r_en     =  'd0;
                        stage1_done    = 1'b0;
                        stage2_done    = 1'b0;
                        stage3_done    = 1'b0;
                        stage4_done    = 1'b0;
                    end
                
        STAGE1:     begin
                        stage1_done  = (w_ptr2 == 'd8);
                        stage2_done  = 1'b0;
                        stage3_done  = 1'b0;
                        stage4_done  = 1'b0;
                        twiddle_sel  = 1'b0;
                        stg2_counter =  'd0;
                        if (stage1_done) begin
                            next_state = STAGE2;
                            counter    = 'd31;
                        end
                        else begin
                            next_state = STAGE1;
                            counter    = counter_r + 1'b1;
                        end

                        
                        if (counter_r[1:0] == 'd2) begin
                            twiddle_addr = 'd4;
                        end
                        else begin
                            twiddle_addr = 'd0;
                        end
                        fifo1_w_en  =  counter_r[1] && (w_ptr1 != 'd8);
                        fifo2_w_en  = ~counter_r[1] && (counter_r != 'd1);
                        fifo1_r_en  =  'd0;
                        fifo2_r_en  =  'd0; 
                    end

        STAGE2:     begin
                        stage1_done = 1'b0;
                        stage2_done = (r_ptr2 == 'd9) ;
                        stage3_done = 1'b0;
                        stage4_done = 1'b0;
                        if (stage2_done) begin
                            next_state = STAGE3;
                            counter    = 'd0;
                            stg2_counter = 'd0;
                        end
                        else begin
                            next_state = STAGE2;
                            counter    = counter_r + 1'b1;
                            if (stg2_counter_r < 'd3) begin // This counter to prevent fifo2_w_en from rising at the beggining of stage2
                                stg2_counter = stg2_counter_r + 1'b1;
                            end
                            else begin
                                stg2_counter = stg2_counter_r;
                            end
                        end

                        case (counter_r[2:0])
                            'd3:  twiddle_addr = 'd0;
                            'd4:  twiddle_addr = 'd4;
                            'd5:  twiddle_addr = 'd2;
                            'd6:  twiddle_addr = 'd6; 
                            default: twiddle_addr = 'd0;
                        endcase

                        if (counter_r[2:0] > 'd5 ) begin
                            twiddle_sel  = ~counter_r[0];
                        end
                        else begin
                            twiddle_sel  = !(|counter_r[2:0]);
                        end
                        fifo1_w_en   = (counter_r[2:0] > 'd1) && (counter_r[2:0] < 'd6); 
                        fifo2_w_en   = ((counter_r[2:0] > 'd5) || (counter_r[2:0] < 'd2)) && (stg2_counter_r > 'd2); //  || stage2_done // counter_r = 6 or 7 or 0 or 1
                        fifo1_r_en   =  counter_r[0];
                        fifo2_r_en   = ~counter_r[0];
                    end

        STAGE3:     begin
                        stage1_done  = 1'b0;
                        stage2_done  = 1'b0;
                        stage3_done  = (w_ptr2 == 'd7);
                        stage4_done  = 1'b0;

                        if (stage3_done) begin
                            next_state = STAGE4;
                            counter = 'd0;
                        end
                        else begin
                            next_state = STAGE3;
                            counter = counter_r + 'd1;
                        end
                        

                        case (counter_r)
                            'd06:    twiddle_addr = 'd4;
                            'd07:    twiddle_addr = 'd2;
                            'd08:    twiddle_addr = 'd6;
                            'd09:    twiddle_addr = 'd1;
                            'd10:    twiddle_addr = 'd5;
                            'd11:    twiddle_addr = 'd3;
                            'd12:    twiddle_addr = 'd7;
                            default: twiddle_addr = 'd0;
                        endcase
                        stg2_counter =  'd0;
                        if (counter_r > 'd5) begin
                            twiddle_sel  = ~counter_r[0];
                        end 
                        else begin
                            twiddle_sel  = !(|counter_r);
                        end

                        fifo1_w_en   =  (counter_r < 'd8); 
                        fifo2_w_en   =  (counter_r > 'd7) && (counter_r < 'd16);
                        fifo1_r_en   =  counter_r[0];
                        fifo2_r_en   = ~counter_r[0];
                        
                    end

        STAGE4:     begin
                        stage1_done  = 1'b0;
                        stage2_done  = 1'b0;
                        stage3_done  = 1'b0;
                        stage4_done  = (w_ptr2 == 'd0);

                        if (stage4_done) begin
                            next_state  = IDLE;
                            counter     = 'd0;
                        end
                        else begin
                            next_state  = STAGE4;
                            counter     = counter_r + 'd1;
                        end
                        twiddle_addr = 'd0;
                        twiddle_sel  = 'd0;
                        stg2_counter = 'd0;
                        fifo1_w_en   =  (counter_r < 'd8); 
                        fifo2_w_en   =  (counter_r > 'd7) && (counter_r < 'd16);
                        fifo1_r_en   =  counter_r[0];
                        fifo2_r_en   = ~counter_r[0];
                    end
        default:    begin
                        stage1_done  = 1'b0;
                        stage2_done  = 1'b0;
                        stage3_done  = 1'b0;
                        stage4_done  = 1'b0;
                        next_state   = IDLE;
                        counter      = 'd0;
                        twiddle_addr = 'd0;
                        twiddle_sel  = 'd0;
                        stg2_counter = 'd0;
                        fifo1_w_en   = 1'b0; 
                        fifo2_w_en   = 1'b0;
                        fifo1_r_en   = 1'b0;
                        fifo2_r_en   = 1'b0;
        end
    endcase
end

assign stage_num = (current_state[1] | current_state[2]); //stage1 -> stage_num = 0 || stage2 -> stage_num = 1;
assign fft_done  = stage4_done;


endmodule