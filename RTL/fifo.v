module fifo #(parameter WORD_LENGTH  = 8, FIFO_DEPTH = 8) (
    output reg  signed [WORD_LENGTH         -1 : 0] data_out,
    output wire                                     empty,
    output wire                                     full,
    output wire        [$clog2(FIFO_DEPTH)  -1 : 0] r_ptr_reg,
    output wire        [$clog2(FIFO_DEPTH)  -1 : 0] w_ptr_reg,
    input  wire signed [WORD_LENGTH         -1 : 0] data_in,
    input  wire                                     w_en,
    input  wire                                     r_en,
    input  wire                                     fft_done,
    input  wire                                     rst,
    input  wire                                     clk
);
localparam PTR_WIDTH = $clog2(FIFO_DEPTH)+1;

reg signed  [WORD_LENGTH -1 : 0] fifo [FIFO_DEPTH -1 : 0];
reg         [PTR_WIDTH   -1 : 0] w_ptr,w_ptr_temp;
reg         [PTR_WIDTH   -1 : 0] r_ptr,r_ptr_temp;
wire                             write;
wire                             read;

initial begin
    fifo[0] = 'd0;    
    fifo[1] = 'd0;
    fifo[2] = 'd0;
    fifo[3] = 'd0;
    fifo[4] = 'd0;
    fifo[5] = 'd0;
    fifo[6] = 'd0;
    fifo[7] = 'd0;
    fifo[8] = 'd0;    
    fifo[9] = 'd0;
    fifo[10] = 'd0;
    fifo[11] = 'd0;
    fifo[12] = 'd0;
    fifo[13] = 'd0;
    fifo[14] = 'd0;
    fifo[15] = 'd0;
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        data_out  <= 'd0;
        w_ptr_temp <= 'd0;
        r_ptr_temp <= 'd0;
    end
    else begin
        w_ptr_temp <= w_ptr;
        r_ptr_temp <= r_ptr;
        if (write) begin
            fifo[w_ptr_temp[PTR_WIDTH-2:0]] <= data_in;
        end
        if (read) begin
            data_out <= fifo[r_ptr_temp[PTR_WIDTH-2:0]];
        end
    end
end

always @(*) begin

    w_ptr = w_ptr_temp;
    r_ptr = r_ptr_temp;

    if (write) begin
        w_ptr = w_ptr_temp + 1'b1;
    end
    if (fft_done) begin
        r_ptr = 'd0;
    end else if (read) begin
        r_ptr = r_ptr_temp + 1'b1;
    end
end

assign full  = (w_ptr_temp[PTR_WIDTH-2:0] == r_ptr_temp[PTR_WIDTH-2:0]) &&  (w_ptr_temp[PTR_WIDTH-1] ^ r_ptr_temp[PTR_WIDTH-1]);
assign empty = (r_ptr_temp == w_ptr_temp);
assign write = w_en && !full;
assign read  = r_en && !empty;
assign w_ptr_reg = w_ptr_temp[$clog2(FIFO_DEPTH)-1 : 0];
assign r_ptr_reg = r_ptr_temp[$clog2(FIFO_DEPTH)-1 : 0];

endmodule