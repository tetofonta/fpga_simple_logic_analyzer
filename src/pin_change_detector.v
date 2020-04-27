module pin_change_detector
#(
    parameter WIDTH = 8
)
(
    input [WIDTH-1:0] i_data,
    input i_clk,
    input inhibit,
    output o_changed
);

reg [WIDTH-1:0] previous = 0;

always @(posedge i_clk)
    previous <= i_data;

assign o_changed = (|(i_data ^ previous)) & ~inhibit;

endmodule