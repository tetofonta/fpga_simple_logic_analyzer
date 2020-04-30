module pin_change_detector
#(
    parameter WIDTH = 8
)
(
    input [WIDTH-1:0] i_data,
    input i_clk,
    input _inhibit,
    output o_changed
);

reg [WIDTH-1:0] previous_pos = 0;
reg [WIDTH-1:0] previous_neg = 0;

always @(posedge i_clk)
    previous_pos <= i_data;

always @(negedge i_clk)
    previous_neg <= i_data;

assign o_changed = ((|(i_data ^ previous_pos)) | (|((i_data ^ previous_neg)))) & _inhibit;

endmodule