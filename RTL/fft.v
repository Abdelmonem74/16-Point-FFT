module fft #(parameter SAMPLE_WORD_LENGTH  = 8, SAMPLE_INT_LENGTH  = 0, SAMPLE_FLOAT_LENGTH  = 7, FIFO_DEPTH = 16) (
    output wire signed [SAMPLE_WORD_LENGTH -1 : 0]  fifo1_dout_i,
    output wire signed [SAMPLE_WORD_LENGTH -1 : 0]  fifo1_dout_q,
    output wire signed [SAMPLE_WORD_LENGTH -1 : 0]  fifo2_dout_i,
    output wire signed [SAMPLE_WORD_LENGTH -1 : 0]  fifo2_dout_q,
    input  wire signed [SAMPLE_WORD_LENGTH -1 : 0]  din_i,
    input  wire signed [SAMPLE_WORD_LENGTH -1 : 0]  din_q,
    input  wire                                     strt_pulse,
    input  wire                                     valid_in,
    input  wire                                     rst,
    input  wire                                     clk
);

localparam  TWIDDLE_WORD_LENGTH  = 8, 
            TWIDDLE_INT_LENGTH   = 0, 
            TWIDDLE_FLOAT_LENGTH = 7,
            PTR_WIDTH            = $clog2(FIFO_DEPTH);

wire in_sel;
wire signed [SAMPLE_WORD_LENGTH -1 :0] out1_i_reg;
wire signed [SAMPLE_WORD_LENGTH -1 :0] out1_q_reg;
wire signed [SAMPLE_WORD_LENGTH -1 :0] out2_i_reg;
wire signed [SAMPLE_WORD_LENGTH -1 :0] out2_q_reg;
wire signed [SAMPLE_WORD_LENGTH -1 :0] in1_i;
wire signed [SAMPLE_WORD_LENGTH -1 :0] in1_q;
wire signed [SAMPLE_WORD_LENGTH -1 :0] in2_i;
wire signed [SAMPLE_WORD_LENGTH -1 :0] in2_q;
wire signed [SAMPLE_WORD_LENGTH -1 :0] fifo1_din_i;
wire signed [SAMPLE_WORD_LENGTH -1 :0] fifo1_din_q;
wire signed [SAMPLE_WORD_LENGTH -1 :0] fifo2_din_i;
wire signed [SAMPLE_WORD_LENGTH -1 :0] fifo2_din_q;
reg  signed [SAMPLE_WORD_LENGTH -1 :0] din_i_r;
reg  signed [SAMPLE_WORD_LENGTH -1 :0] din_q_r;
wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle1_i;
wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle1_q;
wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle2_i;
wire signed [TWIDDLE_WORD_LENGTH-1 :0] twiddle2_q;
wire signed [SAMPLE_WORD_LENGTH -1 :0] in_i,in_fb_i;
wire signed [SAMPLE_WORD_LENGTH -1 :0] in_q,in_fb_q;
reg valid_in_r,valid_in_r_r,valid_in_r_r_r,strt_pulse_r;

wire [5                  -1 : 0] counter;
wire [SAMPLE_WORD_LENGTH -1 : 0] temp_i, temp_q;
wire [PTR_WIDTH          -1 : 0] r_ptr1,r_ptr2,w_ptr1,w_ptr2;
//MUX 1
mux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) mux_U3 (
    .out(in_fb_i),
    .a  (fifo2_dout_i),
    .b  (fifo1_dout_i),
    .sel(counter[0])
);
mux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) mux_U4 (
    .out(in_fb_q),
    .a  (fifo2_dout_q),
    .b  (fifo1_dout_q),
    .sel(counter[0])
);
wire stage_num;
//MUX 2
mux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) mux_U5 (
    .out(in_i),
    .a  (in_fb_i),
    .b  (din_i_r),
    .sel(stage_num)
);
mux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) mux_U6 (
    .out(in_q),
    .a  (in_fb_q),
    .b  (din_q_r),
    .sel(stage_num)
);
//DEMUX 1 
demux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) demux_U0 (
    .out1(in2_i ),
    .out2(in1_i ),
    .in  (in_i ),
    .sel (counter[0])
);

demux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) demux_U1 (
    .out1(in2_q ),
    .out2(in1_q ),
    .in  (in_q  ),
    .sel (counter[0])
);

T_ff T_ff_U0 (
    .q  (in_sel),
    .in (valid_in_r),
    .rst(rst),
    .clk(clk)
);

reg signed [TWIDDLE_WORD_LENGTH -1 : 0] twiddle1_i_r,twiddle1_q_r;
reg signed [SAMPLE_WORD_LENGTH  -1 : 0] in1_i_r,in1_q_r;

radix2 #(   .SAMPLE_WORD_LENGTH (SAMPLE_WORD_LENGTH), .SAMPLE_INT_LENGTH (SAMPLE_INT_LENGTH), .SAMPLE_FLOAT_LENGTH (SAMPLE_FLOAT_LENGTH),
            .TWIDDLE_WORD_LENGTH(TWIDDLE_WORD_LENGTH), .TWIDDLE_INT_LENGTH(TWIDDLE_INT_LENGTH), .TWIDDLE_FLOAT_LENGTH(TWIDDLE_FLOAT_LENGTH)) radix2_U0 (
    .out1_i_reg(out1_i_reg),
    .out1_q_reg(out1_q_reg),
    .out2_i_reg(out2_i_reg),
    .out2_q_reg(out2_q_reg),
    .in1_i     (in1_i_r),
    .in1_q     (in1_q_r),
    .in2_i     (in2_i),
    .in2_q     (in2_q),
    .twiddle1_i(twiddle1_i_r),
    .twiddle1_q(twiddle1_q_r),
    .twiddle2_i(twiddle2_i),
    .twiddle2_q(twiddle2_q),
    .ff_en     (counter[0]),
    .rst       (rst),
    .clk       (clk)
);



mux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) mux_U0 (
    .out(temp_i),
    .a  (out2_i_reg),
    .b  (out1_i_reg),
    .sel(counter[0])
);

mux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) mux_U1 (
    .out(temp_q),
    .a  (out2_q_reg ),
    .b  (out1_q_reg ),
    .sel(counter[0])
);

wire [SAMPLE_WORD_LENGTH*2 -1 : 0] fifo1_dout,fifo2_dout;
wire fifo1_full,fifo2_full,fifo1_w_en,fifo2_w_en,fifo1_r_en,fifo2_r_en,fifo1_empty,fifo2_empty;

demux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) demux_U2 (
    .out1(fifo1_din_i),
    .out2(fifo2_din_i),
    .in  (temp_i ),
    .sel (fifo1_w_en)
);

demux #(.ADDR_WIDTH(SAMPLE_WORD_LENGTH)) demux_U3 (
    .out1(fifo1_din_q),
    .out2(fifo2_din_q),
    .in  (temp_q ),
    .sel (fifo1_w_en)
);

wire fft_done;

fifo #(.WORD_LENGTH(2 * SAMPLE_WORD_LENGTH), .FIFO_DEPTH(FIFO_DEPTH)) fifo_U0 (
    .data_out  (fifo1_dout),
    .empty     (fifo1_empty),
    .full      (fifo1_full),
    .r_ptr_reg (r_ptr1),
    .w_ptr_reg (w_ptr1),
    .data_in   ({fifo1_din_i,fifo1_din_q}),
    .w_en      (fifo1_w_en && valid_in_r_r_r),
    .r_en      (fifo1_r_en),
    .fft_done  (fft_done),
    .rst       (rst),
    .clk       (clk)
); 

fifo #(.WORD_LENGTH(2 * SAMPLE_WORD_LENGTH), .FIFO_DEPTH(FIFO_DEPTH)) fifo_U1 (
    .data_out  (fifo2_dout),
    .empty     (fifo2_empty),
    .full      (fifo2_full),
    .r_ptr_reg (r_ptr2),
    .w_ptr_reg (w_ptr2),
    .data_in   ({fifo2_din_i,fifo2_din_q}),
    .w_en      (fifo2_w_en && valid_in_r_r_r),
    .r_en      (fifo2_r_en),
    .fft_done  (fft_done),
    .rst       (rst),
    .clk       (clk)
);

wire [TWIDDLE_WORD_LENGTH -1 : 0] twiddle_i_reg,twiddle_q_reg;
wire [3                   -1 : 0] address;

twiddles #(.TWIDDLE_WORD_LENGTH(TWIDDLE_WORD_LENGTH), .TWIDDLE_INT_LENGTH(TWIDDLE_INT_LENGTH), .TWIDDLE_FLOAT_LENGTH(TWIDDLE_FLOAT_LENGTH) ) twiddles_U0 (

    .twiddle_i_reg (twiddle_i_reg),
    .twiddle_q_reg (twiddle_q_reg),
    .address       (address),
    .clk           (clk),
    .rst           (rst)
);

wire            twiddle_sel;

ctrl #(.FIFO_DEPTH (FIFO_DEPTH)) ctrl_U0 (
    .twiddle_addr  (address),
    .counter_r     (counter),
    .fifo1_w_en    (fifo1_w_en),
    .fifo2_w_en    (fifo2_w_en),
    .r_ptr1        (r_ptr1),
    .r_ptr2        (r_ptr2),
    .w_ptr1        (w_ptr1),
    .w_ptr2        (w_ptr2),
    .twiddle_sel   (twiddle_sel),
    .fifo1_r_en    (fifo1_r_en),
    .fifo2_r_en    (fifo2_r_en),
    .stage_num     (stage_num),
    .fft_done      (fft_done),
    .fft_strt   (strt_pulse_r),
    .fifo1_full    (fifo1_full),
    .fifo2_full    (fifo2_full),
    .fifo1_empty   (fifo1_empty),
    .fifo2_empty   (fifo2_empty),
    .rst           (rst),
    .clk           (clk)
);

demux #(.ADDR_WIDTH(TWIDDLE_WORD_LENGTH)) demux_U4 (
    .out1(twiddle1_i ),
    .out2(twiddle2_i ),
    .in  (twiddle_i_reg),
    .sel (twiddle_sel)
);

demux #(.ADDR_WIDTH(TWIDDLE_WORD_LENGTH)) demux_U5 (
    .out1(twiddle1_q ),
    .out2(twiddle2_q ),
    .in  (twiddle_q_reg),
    .sel (twiddle_sel)
);





always @(posedge clk or negedge rst) begin
    if (!rst) begin
        twiddle1_i_r    <= 'd0;
        twiddle1_q_r    <= 'd0;
        in1_i_r         <= 'd0;
        in1_q_r         <= 'd0;
        din_i_r         <= 'd0;
        din_q_r         <= 'd0;
        valid_in_r      <= 'd0;
        valid_in_r_r    <= 'd0;
        valid_in_r_r_r  <= 'd0;
        strt_pulse_r    <= 'd0;
    end
    else begin
        if (twiddle_sel) begin
            twiddle1_i_r <= twiddle1_i;
            twiddle1_q_r <= twiddle1_q;
        end
        in1_i_r        <= in1_i;
        in1_q_r        <= in1_q;
        din_i_r        <= din_i;
        din_q_r        <= din_q;
        valid_in_r     <= valid_in;
        valid_in_r_r   <= valid_in_r;
        valid_in_r_r_r <= valid_in_r_r;
        strt_pulse_r   <= strt_pulse;
    end
end


assign fifo1_dout_i = $signed(fifo1_dout[2*SAMPLE_WORD_LENGTH -1 : SAMPLE_WORD_LENGTH]);
assign fifo1_dout_q = $signed(fifo1_dout[  SAMPLE_WORD_LENGTH -1 : 0                 ]);
assign fifo2_dout_i = $signed(fifo2_dout[2*SAMPLE_WORD_LENGTH -1 : SAMPLE_WORD_LENGTH]);
assign fifo2_dout_q = $signed(fifo2_dout[  SAMPLE_WORD_LENGTH -1 : 0                 ]);

endmodule