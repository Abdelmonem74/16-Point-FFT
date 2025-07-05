module T_ff (
    output reg q,
    input wire in,
    input wire rst,
    input wire clk
);

wire d;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        q <= 'd0;
    end
    else begin
        q <= d;
    end
end

assign d = in ^ q;

endmodule